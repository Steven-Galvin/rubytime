require_relative '../spec_helper'
require 'capybara/rspec'

Capybara.app = RubytimeApp

feature 'list projects' do
  before(:all) do
    desc = 'decide whether an arbitrary algorithm halts for a given input'
    create_project('haltingproblem', desc)
  end
  it 'shows a list of projects' do
    visit '/projects'
    expect(page).to have_content('haltingproblem')
  end
end
