# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "muckraker"
  gem.homepage = "http://github.com/benjaminjackson/muckraker"
  gem.license = "MIT"
  gem.summary = %Q{Pretty and informative charts using the NYTimes Campaign Finance API}
  gem.description = %Q{Simple ruby wrapper around the NYTimes/campaign_cash library, which is itself a simple ruby wrapper around the New York Times Campaign Finance API.}
  gem.email = "bhjackson@gmail.com"
  gem.authors = ["Benjamin Jackson"]

  gem.add_dependency "campaign_cash", ">= 2.0.8"
  gem.add_dependency "titlecase", ">= 0.1.1"

end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "muckraker #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
