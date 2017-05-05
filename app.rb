require 'pry-byebug'
require 'sinatra'
require 'sinatra/flash'

if development?
  require 'sinatra/reloader'
  also_reload('**/*.rb')
end

# Sinatra app for Rubytime
class RubytimeApp < Sinatra::Application
  def initialize(app = nil)
    super(app)
    @v_model = Rubytime::Volunteer.new
    @p_model = Rubytime::Project.new
  end

  get('/') do
    erb(:index)
  end

  get('/volunteers') do
    @volunteers = @v_model.all
    erb(:volunteers)
  end

  get('/volunteers/new') do
    @projects = @p_model.all
    erb(:new_volunteer)
  end

  post('/volunteers/new') do
  end

  get('/volunteers/:id') do
    id = params.symbolize.fetch(:id)
    @volunteer = @v_model.where(id: id, include: :project)
    erb(:volunteer)
  end

  patch('/volunteers/:id') do
    id = params.symbolize.fetch(:id)
    @v_model.update(id: id)
  end

  delete('/volunteers/:id') do
    id = params.symbolize.fetch(:id)
    @v_model.delete(id: id)
  end

  get('/projects') do
    @projects = @p_model.all
  end

  get('/projects/new') do
    erb(:new_project)
  end

  post('/projects/new') do
  end

  get('/projects/:id') do
    id = params.symbolize.fetch(:id)
    @project = @p_model.where(id: id)
    erb(:project)
  end

  patch('/projects/:id') do
    id = params.symbolize.fetch(:id)
    @v_model.update(id: id)
  end

  delete('/projects/:id') do
    id = params.symbolize.fetch(:id)
    @v_model.delete(id: id)
  end
end
