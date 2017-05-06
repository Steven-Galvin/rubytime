module RubytimeHelper
  def create_project(title, desc)
    visit '/projects/new'
    fill_in 'project[title]', with: title
    fill_in 'project[description]', with: desc
    within('form') do
      click_on 'New Project'
    end
  end

  def create_volunteer(name)
    create_project('testproject', "ceci n'est pas une test")
    visit '/volunteers/new'
    fill_in 'volunteer[name]', with: name
    first('select option', minimum: 1).select_option
    within('form') do
      click_on 'New Volunteer'
    end
  end
end
