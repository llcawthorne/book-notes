require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test "check dynamic fields" do
    visit store_index_url

    click_on "Add to Cart", match: :first

    click_on "Checkout"
    assert_selector "h1", text: "Please Enter Your Details"

    assert has_no_field? "Routing #"
    assert has_no_field? "Account #"
    assert has_no_field? "CC #"
    assert has_no_field? "Expiry"
    assert has_no_field? "PO #"

    select "Check", from: "Pay with"

    assert has_field? "Routing #"
    assert has_field? "Account #"
    assert has_no_field? "CC #"
    assert has_no_field? "Expiry"
    assert has_no_field? "PO #"

    select "Credit Card", from: "Pay with"

    assert has_no_field? "Routing #"
    assert has_no_field? "Account #"
    assert has_field? "CC #"
    assert has_field? "Expiry"
    assert has_no_field? "PO #"

    select "Purchase Order", from: "Pay with"

    assert has_no_field? "Routing #"
    assert has_no_field? "Account #"
    assert has_no_field? "CC #"
    assert has_no_field? "Expiry"
    assert has_field? "PO #"
  end

  test "check order and delivery" do
    LineItem.delete_all
    Order.delete_all

    visit store_index_url

    click_on "Add to Cart", match: :first

    click_on "Checkout"
    assert_selector "h1", text: "Please Enter Your Details"

    fill_in "Name", with: "Dave Thomas"
    fill_in "Address", with: "123 Main Street"
    fill_in "E-mail", with: "dave@example.com"

    select "Check", from: "Pay with"
    fill_in "Routing #", with: "123456"
    fill_in "Account #", with: "987654"

    click_button "Place Order"
    assert_text "Thank you for your order"

    perform_enqueued_jobs
    perform_enqueued_jobs
    assert_performed_jobs 2

    orders = Order.all
    assert_equal 1, orders.size

    order = orders.first
    assert_equal "Dave Thomas",       order.name
    assert_equal "123 Main Street",   order.address
    assert_equal "dave@example.com",  order.email
    assert_equal "Check",             order.pay_type
    assert_equal 1, order.line_items.size

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "dave@example.com" ],                mail.to
    assert_equal "Sam Ruby <depot@example.com>",        mail[:from].value
    assert_equal "Pragmatic Store Order Confirmation",  mail.subject
  end

  test "emails the customer about the payment failure when Pago declines" do
    LineItem.delete_all
    Order.delete_all

    Pago.stubs(:make_payment).returns(OpenStruct.new(succeeded?: false, error: "Card declined"))

    visit store_index_url

    click_on "Add to Cart", match: :first

    click_on "Checkout"
    assert_selector "h1", text: "Please Enter Your Details"

    fill_in "Name", with: "Dave Thomas"
    fill_in "Address", with: "123 Main Street"
    fill_in "E-mail", with: "dave@example.com"

    select "Check", from: "Pay with"
    fill_in "Routing #", with: "123456"
    fill_in "Account #", with: "987654"

    click_button "Place Order"
    assert_text "Thank you for your order"

    perform_enqueued_jobs
    perform_enqueued_jobs
    assert_performed_jobs 2

    assert_equal 1, Order.count

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "dave@example.com" ], mail.to
    assert_equal "Pragmatic Store Payment Failed", mail.subject
    assert_match "Card declined", mail.body.encoded
  end

  test "sets the ship date through the real edit form and sends a shipped notification" do
    sign_in_as users(:one)
    order = orders(:one)

    visit edit_order_url(order)
    assert_selector "h1", text: "Editing order"

    page.execute_script(<<~JS)
      document.getElementById("order_ship_date").value = "2026-09-20"
    JS

    click_button "Place Order"

    assert_text "Order was successfully updated"
    assert_equal Date.new(2026, 9, 20), order.reload.ship_date

    perform_enqueued_jobs

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ order.email ], mail.to
    assert_equal "Pragmatic Store Order Shipped", mail.subject
  end
end
