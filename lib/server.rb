require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

get '/' do
  "Welcome"
end
