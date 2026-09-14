require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should start a session with valid credentials" do
    assert_difference("@user.sessions.count") do
      post session_url, params: { email_address: @user.email_address, password: "password" }
    end

    assert_redirected_to admin_url
  end

  test "should not start a session with an invalid password" do
    assert_no_difference("@user.sessions.count") do
      post session_url, params: { email_address: @user.email_address, password: "wrong" }
    end

    assert_redirected_to new_session_path
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "should not start a session with an unknown email address" do
    assert_no_difference("Session.count") do
      post session_url, params: { email_address: "nobody@example.com", password: "password" }
    end

    assert_redirected_to new_session_path
  end

  test "should terminate the session on destroy" do
    post session_url, params: { email_address: @user.email_address, password: "password" }

    assert_difference("Session.count", -1) do
      delete session_url
    end

    assert_redirected_to new_session_path
  end

  test "should create the first administrator from whatever was submitted when none exists yet" do
    User.delete_all

    assert_difference("User.count") do
      post session_url, params: { email_address: "new_admin@example.com", password: "secret" }
    end

    assert_redirected_to admin_url

    admin = User.last
    assert_equal "new_admin@example.com", admin.email_address
    assert admin.authenticate("secret")
  end

  test "should not bootstrap an administrator with a blank password" do
    User.delete_all

    assert_no_difference("User.count") do
      post session_url, params: { email_address: "new_admin@example.com", password: "" }
    end

    assert_redirected_to new_session_path
  end

  test "should go back to requiring real credentials once an administrator exists" do
    User.delete_all
    post session_url, params: { email_address: "new_admin@example.com", password: "secret" }
    delete session_url

    assert_no_difference("User.count") do
      post session_url, params: { email_address: "someone_else@example.com", password: "whatever" }
    end

    assert_redirected_to new_session_path
  end
end
