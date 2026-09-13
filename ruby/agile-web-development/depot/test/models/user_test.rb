require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "does not require current_password when the password isn't changing" do
    user = users(:one)
    user.name = "Renamed"

    assert user.valid?
  end

  test "succeeds when current_password matches" do
    user = users(:one)
    user.current_password = "password"
    user.password = "new secret"
    user.password_confirmation = "new secret"

    assert user.valid?
  end

  test "fails when current_password is blank" do
    user = users(:one)
    user.password = "new secret"
    user.password_confirmation = "new secret"

    assert user.invalid?
    assert user.errors[:current_password].any?
  end

  test "fails when current_password is wrong" do
    user = users(:one)
    user.current_password = "not the password"
    user.password = "new secret"
    user.password_confirmation = "new secret"

    assert user.invalid?
    assert_equal [ "is incorrect" ], user.errors[:current_password]
  end

  test "allows the check to be bypassed for the token-verified password reset flow" do
    user = users(:one)
    user.skip_current_password_check = true
    user.password = "new secret"
    user.password_confirmation = "new secret"

    assert user.valid?
  end
end
