require "test_helper"
require "minitest/retry"

# Browser automation carries a baseline flake rate -- Capybara + Selenium +
# headless Chrome occasionally miss a click or race a page transition for
# reasons that don't trace back to the app. Retry system tests a few times
# before failing the run, mirroring rspec-retry's role for the RSpec system
# specs. Scoped to system tests only via classes_to_retry.
Minitest::Retry.use!(retry_count: 3, classes_to_retry: [ "ApplicationSystemTestCase" ])

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  Capybara.default_max_wait_time = 10

  def sign_in_as(user)
    visit new_session_url
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_selector "h1", text: "Welcome"
  end
end
