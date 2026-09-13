require "test_helper"

class OrderTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @order = Order.create!(name: "Dave Thomas", address: "123 Main St", email: "dave@example.com", pay_type: "Check")
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
