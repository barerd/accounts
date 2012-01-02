# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "accounts/version"

Gem::Specification.new do |s|
  s.name        = "accounts"
  s.version     = Accounts::Gem::VERSION
  s.authors     = ["Larry Siden, Westside Consulting LLC"]
  s.email       = ["lsiden@westside-consulting.com"]
  s.homepage    = "https://github.com/lsiden/accounts"
  s.summary     = %q{
*accounts* is a website plug-in that offers than the basic user-account management
and authentication features that many sites need.
  }
  s.description = %q{
Accounts::Server defines the following paths for your web-app:

* POST '/logon'
* POST '/register'
* POST '/forgot-password'
* POST '/change-password'
* POST '/change-email'

Your app must provide the pages and forms that will post to these paths.
  }

  s.rubyforge_project = "accounts"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'sinatra-contrib'
  s.add_development_dependency 'mail-store-agent'
  s.add_development_dependency 'mail-single_file_delivery'
  s.add_development_dependency 'haml'

  s.add_runtime_dependency 'rack', "~>1.3.6" #  https://github.com/rack/rack/issues/299
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'thin'
  s.add_runtime_dependency 'data_mapper'
  s.add_runtime_dependency 'dm-types'
  s.add_runtime_dependency 'dm-timestamps'
  s.add_runtime_dependency 'dm-postgres-adapter'
  s.add_runtime_dependency 'mail'
  s.add_runtime_dependency 'logger'
end
