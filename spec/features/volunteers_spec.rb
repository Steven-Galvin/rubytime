require_relative '../spec_helper'
require 'capybara/rspec'

Capybara.app = RubytimeApp

feature 'list volunteers' do
  before(:all) do
    create_volunteer('J.R. "Bob" Dobbs')
  end
  it 'shows a list of volunteers' do
    visit '/volunteers'
    expect(page).to have_content('J.R. "Bob" Dobbs')
  end
end
