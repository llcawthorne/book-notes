module SystemHelpers
  def sign_in_as(user)
    visit new_session_url
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    expect(page).to have_selector("h1", text: "Welcome")
  end
end
