require "test_helper"

class OrderTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @order = Order.create!(name: "Dave Thomas", address: "123 Main St", email: "dave@example.com", pay_type: "Check")
  end

  test "captures the coupon's discount_percent when a valid code is entered" do
    Coupon.create!(code: "SAVE10", discount_percent: 10)

    order = Order.new(name: "Dave", address: "123 Main St", email: "dave@example.com",
      pay_type: "Check", coupon_code: "save10")

    assert order.valid?
    assert_equal 10, order.discount_percent
  end

  test "rejects an order with an unknown coupon code" do
    order = Order.new(name: "Dave", address: "123 Main St", email: "dave@example.com",
      pay_type: "Check", coupon_code: "NOPE")

    assert order.invalid?
    assert order.errors[:coupon_code].any?
  end

  test "is valid with no coupon code, and applies no discount" do
    order = Order.new(name: "Dave", address: "123 Main St", email: "dave@example.com", pay_type: "Check")

    assert order.valid?
    assert_equal 0, order.discount_percent
  end

  test "rejects an order with an expired coupon code" do
    Coupon.create!(code: "OLD10", discount_percent: 10, expires_on: Date.yesterday)

    order = Order.new(name: "Dave", address: "123 Main St", email: "dave@example.com",
      pay_type: "Check", coupon_code: "old10")

    assert order.invalid?
    assert order.errors[:coupon_code].any?
    assert_equal 0, order.discount_percent
  end

  test "accepts a coupon code that expires today" do
    Coupon.create!(code: "SAVE10", discount_percent: 10, expires_on: Date.current)

    order = Order.new(name: "Dave", address: "123 Main St", email: "dave@example.com",
      pay_type: "Check", coupon_code: "save10")

    assert order.valid?
    assert_equal 10, order.discount_percent
  end

  test "subtotal, discount_amount, and total_price are computed from the line items and discount_percent" do
    @order.discount_percent = 10
    @order.line_items.create!(product: products(:pragprog), quantity: 2, price: products(:pragprog).price)

    assert_equal products(:pragprog).price * 2, @order.subtotal
    assert_equal @order.subtotal * 0.1, @order.discount_amount
    assert_equal @order.subtotal - @order.discount_amount, @order.total_price
  end

  # Mocking a collaborator with Mocha: verifies Pago was actually called with
  # the right arguments, not just that charge! produced the right side effect.
  test "charge! emails the order confirmation when payment succeeds" do
    Pago.expects(:make_payment).with(
      order_id: @order.id,
      payment_method: :check,
      payment_details: { routing: "1", account: "2" }
    ).returns(OpenStruct.new(succeeded?: true))

    assert_enqueued_email_with OrderMailer, :received, args: [ @order ] do
      @order.charge!(routing_number: "1", account_number: "2")
    end
  end

  # Same scenario stubbed by hand instead, for comparison -- see
  # with_pago_result in test_helper.rb. Prefer the Mocha style above for
  # new tests; this is kept as a reference for when a dependency isn't wanted.
  test "charge! emails the customer about the payment failure instead of raising" do
    with_pago_result(OpenStruct.new(succeeded?: false, error: "Card declined")) do
      assert_enqueued_email_with OrderMailer, :payment_failed, args: [ @order, "Card declined" ] do
        @order.charge!(routing_number: "1", account_number: "2")
      end
    end
  end
end
