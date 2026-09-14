require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
    login_as users(:one)
  end

  test "should get index" do
    get orders_url
    assert_response :success
  end

  test "requires item in cart" do
    get new_order_url
    assert_redirected_to store_index_path
    assert_equal "Your cart is empty", flash[:notice]
  end

  test "should get new" do
    post line_items_url, params: { product_id: products(:pragprog).id }

    get new_order_url
    assert_response :success
  end

  test "should create order" do
    assert_difference("Order.count") do
      post orders_url, params: { order: { address: @order.address, email: @order.email, name: @order.name, pay_type: @order.pay_type } }
    end

    assert_redirected_to store_index_url(locale: "en")
  end

  test "should show order" do
    get order_url(@order)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_url(@order)
    assert_response :success
  end

  test "should update order" do
    patch order_url(@order), params: { order: { address: @order.address, email: @order.email, name: @order.name, pay_type: @order.pay_type } }
    assert_redirected_to order_url(@order)
  end

  test "should send a shipped notification when ship_date is set" do
    assert_enqueued_email_with OrderMailer, :shipped, args: [ @order ] do
      patch order_url(@order), params: { order: {
        address: @order.address, email: @order.email, name: @order.name, pay_type: @order.pay_type,
        ship_date: Date.current
      } }
    end
  end

  test "should not send a notification when ship_date is not part of the update" do
    assert_no_enqueued_emails do
      patch order_url(@order), params: { order: {
        address: @order.address, email: @order.email, name: @order.name, pay_type: @order.pay_type
      } }
    end
  end

  test "should not send a notification when ship_date is cleared" do
    @order.update!(ship_date: Date.current)

    assert_no_enqueued_emails do
      patch order_url(@order), params: { order: {
        address: @order.address, email: @order.email, name: @order.name, pay_type: @order.pay_type,
        ship_date: ""
      } }
    end
  end

  test "should destroy order" do
    assert_difference("Order.count", -1) do
      delete order_url(@order)
    end

    assert_redirected_to orders_url
  end

  test "should require authentication to list orders" do
    logout

    get orders_url
    assert_redirected_to new_session_url
  end

  test "should require authentication to view an order" do
    logout

    get order_url(@order)
    assert_redirected_to new_session_url
  end

  test "should require authentication to update an order" do
    logout

    patch order_url(@order), params: { order: { name: "Someone Else" } }
    assert_redirected_to new_session_url
    assert_not_equal "Someone Else", @order.reload.name
  end

  test "should require authentication to destroy an order" do
    logout

    assert_no_difference("Order.count") do
      delete order_url(@order)
    end
    assert_redirected_to new_session_url
  end
end
