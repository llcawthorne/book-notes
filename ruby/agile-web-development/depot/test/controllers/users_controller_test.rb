require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    login_as @user
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: {
        email_address: "sam@example.org",
        name: "sam",
        password: "secret",
        password_confirmation: "secret" } }
    end

    assert_redirected_to users_url
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: {
      email_address: @user.email_address,
      name: @user.name } }
    assert_redirected_to users_url
  end

  test "should update the password when the current password is correct" do
    patch user_url(@user), params: { user: {
      email_address: @user.email_address,
      name: @user.name,
      current_password: "password",
      password: "secret",
      password_confirmation: "secret" } }
    assert_redirected_to users_url

    assert @user.reload.authenticate("secret")
  end

  test "should not update the password when the current password is missing" do
    patch user_url(@user), params: { user: {
      email_address: @user.email_address,
      name: @user.name,
      password: "secret",
      password_confirmation: "secret" } }
    assert_response :unprocessable_content
    assert_not @user.reload.authenticate("secret")
  end

  test "should not update the password when the current password is wrong" do
    patch user_url(@user), params: { user: {
      email_address: @user.email_address,
      name: @user.name,
      current_password: "not the password",
      password: "secret",
      password_confirmation: "secret" } }
    assert_response :unprocessable_content
    assert_not @user.reload.authenticate("secret")
  end

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end

  test "should require authentication to list users" do
    logout

    get users_url
    assert_redirected_to new_session_url
  end

  test "should require authentication to view a user" do
    logout

    get user_url(@user)
    assert_redirected_to new_session_url
  end

  test "should require authentication to update a user" do
    logout

    patch user_url(@user), params: { user: { name: "Hijacked Name" } }
    assert_redirected_to new_session_url
    assert_not_equal "Hijacked Name", @user.reload.name
  end

  test "should require authentication to destroy a user" do
    logout

    assert_no_difference("User.count") do
      delete user_url(@user)
    end
    assert_redirected_to new_session_url
  end
end
