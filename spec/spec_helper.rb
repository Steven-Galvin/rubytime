ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require_relative '../boot'
require 'lib/tasks/db'
require 'database_cleaner'
require 'timecop'

# this is necessary for the database cleaner not to fall over.
Sequel.connect(ENV['DATABASE_URL_TEST'])

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
