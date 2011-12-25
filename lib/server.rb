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

get '/forgot-password' do
  haml :forgot_password
end

post '/forgot-password' do
  haml :forgot_password_comfirm
end
