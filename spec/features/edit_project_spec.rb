require_relative '../spec_helper'
require 'capybara/rspec'

Capybara.app = RubytimeApp

feature 'project individual page' do
  before(:all) do
    desc = 'decide whether an arbitrary algorithm halts for a given input'
    create_project('haltingproblem', desc)
  end
  it 'allows editing of the project' do
    visit '/projects'
    first('.project').click_on 'haltingproblem'
    fill_in 'project[title]', with: 'deathstar'
    fill_in 'project[description]', with: 'build a "death star"'
    click_on 'Edit Project'
    expect(page).to have_current_path(%r{projects/\d})
    expect(page).to have_content 'build a "death star"'
    expect(page).to have_content 'deathstar'
  end
  it 'allows deletion of the project' do
    visit '/projects'
    count = all('.project').count
    first('.project > a').click
    click_on 'Delete Project'
    expect(page).to have_current_path('/projects')
    expect(all('.project').count).to eq(count - 1)
  end
end
