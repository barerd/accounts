require 'rubygems'
require 'cucumber/rake/task'
 
Cucumber::Rake::Task.new(:features) do |t|
  tag = ENV["tag"] ? ENV["tag"].split(',').map {|t| "@" + t}.join(',') : "all"
  t.cucumber_opts = "--format pretty -t #{tag}"
  # see http://autotestgroup.com/en/blog/80.html
end
