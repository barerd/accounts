require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test)
require 'model'

# TODO - This uses a cookied.
# You might want to replace this with something like Rack::Session::Pool
enable :sessions

configure :development do
  Mail.defaults do
    delivery_method Mail::SingleFileDelivery::Agent, :filename => '/tmp/mail-test-fifo'
  end
end

configure :test do
  DataMapper.auto_migrate!  # empty database
  STDERR.puts "called DataMapper.auto_migrate!"

  Mail.defaults do
    delivery_method(:test)
    Mail::TestMailer.deliveries = MailStoreAgent.new
  end
end

helpers do
  require 'server/helpers.rb'
  include Accounts::Helpers
end

module Accounts
  class AccountsError; end
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
  @email = params[:email] || ''
  haml :logon
end

post '/logon' do
  email = params[:email]
  password = params[:password]

  if authenticate! email, password then
    redirect to('/welcome')
  else
    session[:account_id] = nil
    return 403
  end
end

get '/logout' do
  session[:account_id] = nil
  redirect to('/logon')
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
  account = Authenticatable::Account.first({ :email => email })
  case
  when !account
    register_new_account email
    return "Check your e-mail."
  when account.status.include?(:email_confirmed)
    return %Q{#{email} is already registered.  You may <a href="/logon?email=#{email}"log on</a>.}
  else
    send_change_password_link account
    return "#{email} is already registered.  Check your e-mail to change your password."
  end
end

get '/forgot-password' do
  haml :forgot_password
end

post '/forgot-password' do
  email = params[:email]
  account = Authenticatable::Account.first({ :email => email }) \
    or return "#{email} does not match any account"
  send_change_password_link account
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
  send_change_password_confirmation account
  "You have changed your password."
end

get '/change-email' do
  return 403 unless session[:account_id]
  haml :change_email
end

post '/change-email' do
  return 403 unless session[:account_id]
  account = Authenticatable::Account.get(session[:account_id]) \
    or return 403
  new_email = params[:email]
  Authenticatable::Account.count(:email => new_email) == 0 \
    or return "#{new_email} is already taken"
  send_change_email_confirmation account, new_email
  send_change_email_notification account, new_email
  "Check your e-mail."
end
