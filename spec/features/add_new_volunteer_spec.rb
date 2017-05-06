require_relative '../spec_helper'
require 'capybara/rspec'

Capybara.app = RubytimeApp

feature 'add new volunteer' do
  it 'adds a new volunteer' do
    create_project('testproject', "ceci n'est pas une test")
    visit '/volunteers/new'
    fill_in 'volunteer[name]', with: 'Radical Edward'
    first('select option', minimum: 1).select_option
    within('form') do
      click_on 'New Volunteer'
    end
    expect(page).to have_current_path('/volunteers')
    expect(page).to have_content 'Radical Edward'
  end
end
