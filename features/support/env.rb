# Copyright Westside Consulting LLC, Ann Arbor, MI, USA, 2012

require './demo/web_app'
require 'capybara/cucumber'

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
