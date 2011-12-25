require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test)

get '/' do
  "Welcome"
end

get '/logon' do
  haml :login
end
