require 'bundler/gem_tasks'
require 'rake/testtask'

namespace :test do
  desc 'Run unit tests'
  Rake::TestTask.new(:units) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/**/*_test.rb']
  end
end

task default: 'test:units'
