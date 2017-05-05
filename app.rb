require 'pry-byebug'
require 'sinatra'
require 'sinatra-flash'

if development?
  require 'sinatra/reloader'
  also_reload('**/*.rb')
end

# Sinatra app for Rubytime
class RubytimeApp < Sinatra::Application
  def initialize(app = nil)
    super(app)
  end

  get('/') do
    erb(:index)
  end
end
