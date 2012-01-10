source :rubygems

gem 'data_mapper'
gem 'dm-types'
gem 'dm-timestamps'
gem 'dm-postgres-adapter'
gem 'mail'
gem "rack", :git => "git://github.com/rack/rack.git"
gem 'sinatra', :require => 'sinatra/base'
gem "selenium-webdriver", "!= 2.16.0" # broken

group :demo do
  gem 'logger'
  gem 'rspec'
  gem 'sinatra-contrib'
  gem 'mail-store-agent'
  gem 'mail-single_file_delivery'
  gem 'haml'
  gem 'accounts', :path => '.'
end

group :cucumber do
  gem 'cucumber'
  gem 'capybara', :require => ['capybara/cucumber']
end
