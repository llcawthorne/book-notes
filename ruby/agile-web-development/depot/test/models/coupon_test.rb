require "test_helper"

class CouponTest < ActiveSupport::TestCase
  test "is valid with a code and a discount percentage" do
    coupon = Coupon.new(code: "SAVE10", discount_percent: 10)
    assert coupon.valid?
  end

  test "requires a code" do
    coupon = Coupon.new(discount_percent: 10)
    assert coupon.invalid?
    assert coupon.errors[:code].any?
  end

  test "requires a discount percent between 1 and 100" do
    coupon = Coupon.new(code: "SAVE10")

    coupon.discount_percent = 0
    assert coupon.invalid?

    coupon.discount_percent = 101
    assert coupon.invalid?

    coupon.discount_percent = 10
    assert coupon.valid?
  end

  test "normalizes the code to a stripped, upcased form" do
    coupon = Coupon.create!(code: "  save10  ", discount_percent: 10)
    assert_equal "SAVE10", coupon.code
  end

  test "rejects a duplicate code regardless of case or whitespace" do
    Coupon.create!(code: "SAVE10", discount_percent: 10)

    duplicate = Coupon.new(code: " save10 ", discount_percent: 20)
    assert duplicate.invalid?
    assert duplicate.errors[:code].any?
  end

  test "is not expired when expires_on is blank" do
    coupon = Coupon.new(code: "SAVE10", discount_percent: 10)
    assert_not coupon.expired?
  end

  test "is not expired when expires_on is today or in the future" do
    coupon = Coupon.new(code: "SAVE10", discount_percent: 10, expires_on: Date.current)
    assert_not coupon.expired?

    coupon.expires_on = Date.tomorrow
    assert_not coupon.expired?
  end

  test "is expired when expires_on is in the past" do
    coupon = Coupon.new(code: "SAVE10", discount_percent: 10, expires_on: Date.yesterday)
    assert coupon.expired?
  end
end
