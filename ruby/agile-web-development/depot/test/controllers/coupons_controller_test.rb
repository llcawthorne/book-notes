require "test_helper"

class CouponsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @coupon = Coupon.create!(code: "SAVE10", discount_percent: 10)
    login_as users(:one)
  end

  test "should get index" do
    get coupons_url
    assert_response :success
  end

  test "should get new" do
    get new_coupon_url
    assert_response :success
  end

  test "should create coupon" do
    assert_difference("Coupon.count") do
      post coupons_url, params: { coupon: { code: "SAVE20", discount_percent: 20 } }
    end

    assert_redirected_to coupons_url
  end

  test "should create a coupon with an expiration date" do
    post coupons_url, params: { coupon: { code: "SAVE20", discount_percent: 20, expires_on: Date.tomorrow } }

    assert_equal Date.tomorrow, Coupon.find_by(code: "SAVE20").expires_on
  end

  test "should not create an invalid coupon" do
    assert_no_difference("Coupon.count") do
      post coupons_url, params: { coupon: { code: "", discount_percent: 20 } }
    end

    assert_response :unprocessable_content
  end

  test "should destroy coupon" do
    assert_difference("Coupon.count", -1) do
      delete coupon_url(@coupon)
    end

    assert_redirected_to coupons_url
  end

  test "should require authentication to list coupons" do
    logout
    get coupons_url
    assert_redirected_to new_session_url
  end

  test "should require authentication to create a coupon" do
    logout

    assert_no_difference("Coupon.count") do
      post coupons_url, params: { coupon: { code: "SAVE20", discount_percent: 20 } }
    end

    assert_redirected_to new_session_url
  end

  test "should require authentication to destroy a coupon" do
    logout

    assert_no_difference("Coupon.count") do
      delete coupon_url(@coupon)
    end

    assert_redirected_to new_session_url
  end
end
