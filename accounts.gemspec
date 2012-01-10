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


end
