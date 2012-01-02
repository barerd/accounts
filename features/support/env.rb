# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler/setup'
Bundler.require(:test)
require 'capybara/cucumber'
require 'accounts'
require 'test/web_app'

#Capybara.app = Sinatra::Application::new
Capybara.app = MyWebApp

class AccountsWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

World do |;world|
  world = AccountsWorld.new
  #STDERR.puts world.class.included_modules
  #File.open("/tmp/methods.txt", "w").puts world.methods 
end
