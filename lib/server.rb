require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test)
require 'model'

# TODO - This uses a cookied.
# You might want to replace this with something like Rack::Session::Pool
enable :sessions

configure :test do
  DataMapper.auto_migrate!  # empty database
  STDERR.puts "called DataMapper.auto_migrate!"
end

helpers do
  require 'server/helpers.rb'
  include Accounts::Helpers
end

error Accounts::AccountsError do
  env['sinatra.error'].return_error_page
end

not_found do
  %Q{Page not found.  Go to <a href="home">home page</a>.}
end

error 403 do
  "Access denied"
end

get '/' do
  "Welcome"
end

get '/logon' do
  haml :logon
end

post '/logon' do
  email = params[:email]
  password = params[:password]

  if authenticate! email, password then
    redirect '/welcome'
  else
    session[:account_id] = nil
    return 403
  end
end

get '/logout' do
  session[:account_id] = nil
  redirect '/logon'
end

get '/welcome' do
  account = Authenticatable::Account.get(session[:account_id]) or return 403
  "Welcome #{account.email}"
end

get '/register' do
  haml :register
end

post '/register' do
  email = params[:email]
  account = Authenticatable::Account.first ({ :email => email })

  if account then
    Accounts::Helpers.send_change_password_link account
    return %Q{#{email} is already registered.  Check your e-mail to change your password.}
  else
    # TODO refactor this into a helper to shorten
    account = Authenticatable::Account.create ({ :email => email })
    account.saved? or return "Sorry. We cannot register you at this time.  Please try again later."
    Accounts::Helpers.send_registration_confirmation account
    return "Check your e-mail."
  end
end

get '/forgot-password' do
  haml :forgot_password
end

post '/forgot-password' do
  email = params[:email]
  account = Authenticatable::Account.first({ :email => email }) \
    or return "#{email} does not match any account"
  Accounts::Helpers.send_change_password_link account
  "Check your e-mail to change your password."
end

get '/response-token/:token' do
  respond_to_token params[:token]
end

get '/change-password' do
  return 403 unless session[:account_id]
  haml :change_password
end

post '/change-password' do
  return 403 unless session[:account_id]
  account = Authenticatable::Account.get(session[:account_id]) \
    or return 403
  account.set_password params[:password]
  Accounts::Helpers.send_change_password_confirmation account
  "You have changed your password."
end
