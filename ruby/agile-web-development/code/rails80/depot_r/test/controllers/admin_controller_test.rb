#---
# Excerpted from "Agile Web Development with Rails 8",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/rails8 for more book information.
#---
require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get index if logged in as admin" do
    login_as users(:one)
    get admin_url
    assert_response :success
  end

  test "should be redirected if not logged in" do
    get admin_url
    assert_redirected_to new_session_url
  end
end
