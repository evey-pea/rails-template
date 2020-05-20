require "application_system_test_case"

class ProfilesTest < ApplicationSystemTestCase
  setup do
    @profile = profiles(:one)
  end

  test "visiting the index" do
    visit profiles_url
    assert_selector "h1", text: "Profiles"
  end

  test "creating a Profile" do
    visit profiles_url
    click_on "New Profile"

    fill_in "City", with: @profile.city
    fill_in "Country", with: @profile.country
    fill_in "Description", with: @profile.description
    fill_in "Name display", with: @profile.name_display
    fill_in "Name first", with: @profile.name_first
    fill_in "Name second", with: @profile.name_second
    fill_in "Postcode", with: @profile.postcode
    fill_in "Road", with: @profile.road
    fill_in "State", with: @profile.state
    fill_in "Street number", with: @profile.street_number
    fill_in "Suburb", with: @profile.suburb
    fill_in "User", with: @profile.user_id
    click_on "Create Profile"

    assert_text "Profile was successfully created"
    click_on "Back"
  end

  test "updating a Profile" do
    visit profiles_url
    click_on "Edit", match: :first

    fill_in "City", with: @profile.city
    fill_in "Country", with: @profile.country
    fill_in "Description", with: @profile.description
    fill_in "Name display", with: @profile.name_display
    fill_in "Name first", with: @profile.name_first
    fill_in "Name second", with: @profile.name_second
    fill_in "Postcode", with: @profile.postcode
    fill_in "Road", with: @profile.road
    fill_in "State", with: @profile.state
    fill_in "Street number", with: @profile.street_number
    fill_in "Suburb", with: @profile.suburb
    fill_in "User", with: @profile.user_id
    click_on "Update Profile"

    assert_text "Profile was successfully updated"
    click_on "Back"
  end

  test "destroying a Profile" do
    visit profiles_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Profile was successfully destroyed"
  end
end
