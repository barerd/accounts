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
  if ( Authenticatable::Account.count( :email => @email ) != 0) then
    return %Q{#{@email} is already registered.  Please <a href="/logon">log on</a>.}
  end
  Accounts::Helpers.mail_registration_confirmation @email
  haml :register_confirm
end

get '/forgot-password' do
  haml :forgot_password
end

post '/forgot-password' do
  @email = params[:email]
  haml :forgot_password_confirm
end
