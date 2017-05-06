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

  def params
    super.symbolize
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
    data = params.fetch(:volunteer)
    @v_model.save(data)
    redirect('/volunteers')
  end

  get('/volunteers/:id') do
    id = params.fetch(:id)
    @projects = @p_model.all
    c = { 'volunteers.id'.to_sym => id }
    @volunteer = @v_model.where(conditions: c, p_include: :projects)
    erb(:volunteer)
  end

  put('/volunteers/:id') do
    id = params.fetch(:id)
    data = params.fetch(:volunteer)
    @v_model.update(id, data)
    redirect('/volunteers/' + id)
  end

  delete('/volunteers/:id') do
    id = params.fetch(:id)
    @v_model.delete(id)
    redirect('/volunteers')
  end

  get('/projects') do
    @projects = @p_model.all
    erb(:projects)
  end

  get('/projects/new') do
    erb(:new_project)
  end

  post('/projects/new') do
    data = params.fetch(:project)
    @p_model.save(data)
    redirect('/projects')
  end

  get('/projects/:id') do
    id = params.fetch(:id)
    @project = @p_model.where(id: id)
    erb(:project)
  end

  put('/projects/:id') do
    id = params.fetch(:id)
    data = params.fetch(:project)
    @p_model.update(id, data)
    redirect('/projects/' + id)
  end

  delete('/projects/:id') do
    id = params.fetch(:id)
    @p_model.delete(id)
    redirect('/projects')
  end
end
