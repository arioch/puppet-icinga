require 'rake'
require 'rubygems'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'

RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
  #t.rspec_opts = "--format documentation --color"
end

task :default => :rspec
