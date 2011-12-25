require 'rubygems'
require 'cucumber/rake/task'
 
Cucumber::Rake::Task.new(:features) do |t|
  tag = ENV["tag"]
  t.cucumber_opts = "--format pretty -t #{ tag ? "@#{tag}" : 'all' } "
end
