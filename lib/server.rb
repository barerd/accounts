require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test)
require 'model'

configure :test do
  DataMapper.auto_migrate!  # empty database
  STDERR.puts "called DataMapper.auto_migrate!"
  #exit
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

get '/' do
  "Welcome"
end

get '/logon' do
  haml :logon
end

get '/register' do
  haml :register
end

post '/register' do
  @email = params[:email]
  account = Authenticatable::Account.first ({ :email => @email })

  if account then
    Accounts::Helpers.mail_change_password_link account
    return %Q{#{@email} is already registered.  
      We are sending #{@email} another e-mail with a link that will allow you to change your password.}
  else
    account = Authenticatable::Account.create ({ :email => @email })

    if !account.saved? then
      return "Sorry. We cannot register you at this time.  Please try again later."
    end
    Accounts::Helpers.mail_registration_confirmation account
    haml :register_confirm
  end
end

get '/forgot-password' do
  haml :forgot_password
end

post '/forgot-password' do
  @email = params[:email]
  haml :forgot_password_confirm
end

get '/response-token/:token' do
  respond_to_token params[:token]
end

get '/change-password' do
  haml :change_password
end

post '/change-password' do
  "You have changed your password.  We are sending you a confirmation e-mail."
end
