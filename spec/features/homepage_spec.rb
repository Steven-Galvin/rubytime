require_relative '../spec_helper'
require 'capybara/rspec'

Capybara.app = RubytimeApp

feature 'Homepage' do
  it 'shows the home page' do
    visit '/'
    expect(page).to have_content 'RubyTime'
    expect(page).to have_link 'New Project'
    expect(page).to have_link 'Projects'
    expect(page).to have_link 'New Volunteer'
    expect(page).to have_link 'Volunteers'
  end
end
