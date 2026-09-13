require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cart = carts(:one)
    login_as users(:one)
  end

  test "should get index" do
    get carts_url
    assert_response :success
  end

  test "index should only list the cart in session, not every visitor's cart" do
    my_cart = current_session_cart

    get carts_url

    assert_select "#cart_#{my_cart.id}"
    assert_select "#cart_#{carts(:one).id}", false
  end

  test "should get new" do
    get new_cart_url
    assert_response :success
  end

  test "should create cart" do
    assert_difference("Cart.count") do
      post carts_url, params: { cart: {} }
    end

    assert_redirected_to cart_url(Cart.last)
  end

  test "should show the cart in session" do
    my_cart = current_session_cart

    get cart_url(my_cart)
    assert_response :success
  end

  test "should get edit for the cart in session" do
    my_cart = current_session_cart

    get edit_cart_url(my_cart)
    assert_response :success
  end

  test "should update the cart in session" do
    my_cart = current_session_cart

    patch cart_url(my_cart), params: { cart: {} }
    assert_redirected_to cart_url(my_cart)
  end

  test "should not show a cart other than the one in session" do
    current_session_cart
    other_cart = carts(:one)

    get cart_url(other_cart)

    assert_redirected_to store_index_url
  end

  test "should notify the system administrator when accessing an invalid cart" do
    current_session_cart
    other_cart = carts(:one)

    assert_enqueued_email_with SystemMailer, :error_notification,
      args: [ "Attempt to access invalid cart #{other_cart.id}" ] do
      get cart_url(other_cart)
    end
  end

  test "should not edit a cart other than the one in session" do
    current_session_cart
    other_cart = carts(:one)

    get edit_cart_url(other_cart)

    assert_redirected_to store_index_url
  end

  test "should not destroy a cart other than the one in session" do
    current_session_cart
    other_cart = carts(:one)

    assert_no_difference("Cart.count") do
      delete cart_url(other_cart)
    end

    assert_redirected_to store_index_url
  end

  test "should destroy cart" do
    my_cart = current_session_cart

    assert_difference("Cart.count", -1) do
      delete cart_url(my_cart)
    end

    assert_redirected_to store_index_url
  end

  test "should empty the cart via turbo-stream without redrawing the whole page" do
    my_cart = current_session_cart

    delete cart_url(my_cart), as: :turbo_stream

    assert_response :success
    assert_match /<turbo-stream action="replace" target="cart">/, @response.body
    assert_match /Your cart is currently empty/, @response.body
    assert_no_match /The Pragmatic Programmer/, @response.body
  end

  private
    # Adding a line item is the app's own mechanism for tying a Cart to the
    # current session, so exercise that instead of poking session[:cart_id]
    # directly.
    def current_session_cart
      post line_items_url, params: { product_id: products(:pragprog).id }
      Cart.find(session[:cart_id])
    end
end
