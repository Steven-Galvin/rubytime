require_relative '../spec_helper'
require 'capybara/rspec'

Capybara.app = RubytimeApp

feature 'volunteer individual page' do
  before(:all) do
    create_volunteer 'why'
  end

  it 'allows editing of the volunteer' do
    create_project('panther_moderns', 'infiltrate Sense/Net')
    visit '/volunteers'
    first('.volunteer').click_on 'a' # next link (inside li)
    fill_in 'volunteer[name]', with: 'Hiro Protagonist'
    select 'panther_moderns', from: 'volunteer[project_id]'
    within('form#edit') do
      click_on 'Edit Volunteer'
    end
    expect(page).to have_current_path(%r{volunteers/\d})
    expect(page).to have_content 'Hiro Protagonist'
    expect(page).to have_content 'panther_moderns'
  end

  it 'allows deletion of the volunteer' do
    visit '/volunteers'
    count = all('.volunteer').count
    first('.volunteer > a').click
    click_on 'Delete Volunteer'
    expect(page).to have_current_path('/volunteers')
    expect(all('.volunteer').count).to eq(count - 1)
  end
end
