$LOAD_PATH.unshift('./')

require 'sequel'
require 'app'
require 'dotenv'

Dotenv.load

env = ENV['RACK_ENV'] || 'development'

connection_string = ENV['DATABASE_URL'] || ENV["DATABASE_URL_#{env.upcase}"]

DB = PG::Connection.open(connection_string)
