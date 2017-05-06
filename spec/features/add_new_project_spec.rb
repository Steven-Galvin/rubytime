require_relative '../spec_helper'
require 'capybara/rspec'

Capybara.app = RubytimeApp

feature 'Add project' do
  it 'shows a new project form' do
    visit '/projects/new'
    expect(page).to have_content('New Project')
  end

  it 'creates a new project' do
    visit '/projects/new'
    fill_in 'project[title]', with: 'haltingproblem'
    desc = 'decide whether an arbitrary algorithm halts for a given input'
    fill_in 'project[description]', with: desc
    within('form') do
      click_on 'New Project'
    end
    expect(page).to have_current_path('/projects')
    expect(page).to have_content('haltingproblem')
  end
end
