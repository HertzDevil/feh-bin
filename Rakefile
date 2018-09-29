require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :test

Rake::TestTask.new(:test) do |t|
  t.description = 'Run unit tests'
  t.libs << 'lib'
  t.test_files = FileList['spec/**/*_spec.rb']
end
