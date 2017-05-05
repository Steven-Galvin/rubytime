require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'fileutils'
require 'logger'
require 'rake'
require 'dotenv/tasks'
require 'pry-byebug'

task :default do
  puts 'Available tasks:'
  Rake.application.options.show_tasks = true
  Rake.application.options.full_description = false
  Rake.application.options.show_task_pattern = //
  Rake.application.display_tasks_and_comments
end

task :env do
  require "#{File.dirname(__FILE__)}/app.rb"
end

begin
  desc 'Run all tests'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
    t.rspec_opts = ['--backtrace', '--colour', '-fd']
  end
end

namespace :db do
  desc 'Run migrations up to specified version or to latest.'
  task :migrate, [:version] => [:dotenv] do |_, args|
    require 'sequel'
    Sequel.extension :migration

    env = ENV['RACK_ENV'] || 'development'
    version = args[:version]
    migs_dir = 'migrations'
    connection_string = ENV['DATABASE_URL'] || ENV["DATABASE_URL_#{env.upcase}"]

    raise 'Missing Connection string' if connection_string.nil?
    db = Sequel.connect(connection_string)
    message = if args[:version].nil?
                Sequel::Migrator.run(db, migs_dir)
                'Migrated to latest'
              else
                Sequel::Migrator.run(db, migs_dir, target: version.to_i)
                "Migrated to version #{version}"
              end

    puts message if env != 'test'
  end
end
