#require "bundler/gem_tasks"
require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

desc "Run RSpec"
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.ruby_opts = %w[-w]
  t.ruby_opts << ENV["opts"] if ENV["opts"]
end
 
desc "Run Cucumber"
Cucumber::Rake::Task.new(:features) do |t|
  tag = ENV["tag"].split(',').map {|t| "@#{t}" }.join(',') if ENV["tag"]
  t.cucumber_opts = "--format pretty"
  t.cucumber_opts += %W[-t #{tag}] if tag
  #STDERR.puts t.cucumber_opts.inspect
  # see http://autotestgroup.com/en/blog/80.html
end
