require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test)

configure :test do
  ENV['DEVEL'] = '1'  # wipes database
end

helpers do
  require File.dirname(__FILE__) + '/server/helpers.rb'
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
