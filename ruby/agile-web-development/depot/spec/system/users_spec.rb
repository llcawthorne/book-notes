require "rails_helper"

RSpec.describe "Users", type: :system do
  fixtures :users

  let(:user) { users(:one) }

  before { sign_in_as users(:two) }

  describe "visiting the index" do
    it "lists the users" do
      visit users_url

      expect(page).to have_selector("h1", text: "Users")
    end
  end

  describe "creating a user" do
    it "creates the user and shows a confirmation" do
      visit users_url
      expect(page).to have_selector("h1", text: "Users")

      click_on "New user"
      expect(page).to have_selector("h1", text: "New user")

      fill_in "Email address", with: "new_user@example.com"
      fill_in "Name", with: "New User"
      fill_in "user_password", with: "secret"
      fill_in "Confirm:", with: "secret"
      click_on "Create User"

      expect(page).to have_text("was successfully created")
    end
  end

  describe "updating a user" do
    it "updates the user and shows a confirmation" do
      visit user_url(user)
      expect(page).to have_selector("h1", text: "Showing user")

      click_on "Edit this user", match: :first
      expect(page).to have_selector("h1", text: "Editing user")

      fill_in "Email address", with: user.email_address
      fill_in "Name", with: user.name
      fill_in "user_current_password", with: "password"
      fill_in "user_password", with: "secret"
      fill_in "Confirm:", with: "secret"
      click_on "Update User"

      expect(page).to have_text("was successfully updated")
    end

    it "rejects the new password when the current password is wrong" do
      visit user_url(user)
      click_on "Edit this user", match: :first
      expect(page).to have_selector("h1", text: "Editing user")

      fill_in "Email address", with: user.email_address
      fill_in "Name", with: user.name
      fill_in "user_current_password", with: "not the password"
      fill_in "user_password", with: "secret"
      fill_in "Confirm:", with: "secret"
      click_on "Update User"

      expect(page).to have_text("is incorrect")
      expect(user.reload.authenticate("secret")).to be_falsy
    end
  end

  describe "destroying a user" do
    it "removes the user and shows a confirmation" do
      visit user_url(user)
      expect(page).to have_selector("h1", text: "Showing user")

      accept_confirm { click_on "Destroy this user", match: :first }

      expect(page).to have_text("deleted")
    end
  end
end
