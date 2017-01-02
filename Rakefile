require 'bundler/gem_tasks'
require 'rake/testtask'

namespace :test do
  desc 'Run unit tests'
  Rake::TestTask.new(:units) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/sprockets/bumble_d/**/*_test.rb']
  end

  namespace :integration do
    desc 'Resolve and install dependencies for all test apps'
    task :install do
      test_apps_pattern = 'test/test_apps/[0-9]*'
      Dir.glob(test_apps_pattern).each do |test_app_directory|
        gemfile_path = File.expand_path("../#{test_app_directory}/Gemfile", __FILE__)
        test_app_path = File.expand_path("../#{test_app_directory}", __FILE__)

        specific_gemfile_env = Bundler.clean_env
        specific_gemfile_env['BUNDLE_GEMFILE'] = gemfile_path

        Bundler.send(:with_env, specific_gemfile_env) do
          exit_status_was_zero = system("cd #{test_app_path} && bundle check || bundle install")
          raise unless exit_status_was_zero
        end
      end
    end
  end
end

task default: 'test:units'
