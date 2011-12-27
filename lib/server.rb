require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test)

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
  haml :register_confirm
end

get '/forgot-password' do
  haml :forgot_password
end

post '/forgot-password' do
  @email = params[:email]
  haml :forgot_password_confirm
end
