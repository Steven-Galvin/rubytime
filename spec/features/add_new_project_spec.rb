require 'spec_helper'
require 'capybara/rspec'

Capybara.app = RubytimeApp

feature 'Add project' do
  it 'shows a new project form' do
    visit '/projects/new'
    expect(page).to have_content('New Project')
  end
end
