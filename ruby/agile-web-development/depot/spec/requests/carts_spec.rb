require "rails_helper"

RSpec.describe "Carts", type: :request do
  fixtures :carts, :users, :products

  before { login_as users(:one) }

  let(:cart) { carts(:one) }

  # Adding a line item is the app's own mechanism for tying a Cart to the
  # current session, so exercise that instead of poking session[:cart_id]
  # directly.
  def current_session_cart
    post line_items_url, params: { product_id: products(:pragprog).id }
    Cart.find(session[:cart_id])
  end

  describe "GET /carts" do
    it "renders successfully" do
      get carts_url
      expect(response).to be_successful
    end

    it "only lists the cart in session, not every visitor's cart" do
      my_cart = current_session_cart

      get carts_url

      assert_select "#cart_#{my_cart.id}"
      assert_select "#cart_#{cart.id}", false
    end
  end

  describe "GET /carts/new" do
    it "renders successfully" do
      get new_cart_url
      expect(response).to be_successful
    end
  end

  describe "POST /carts" do
    it "creates a cart and redirects to it" do
      expect {
        post carts_url, params: { cart: {} }
      }.to change(Cart, :count).by(1)

      expect(response).to redirect_to(cart_url(Cart.last))
    end
  end

  describe "GET /carts/:id" do
    it "renders the cart in session successfully" do
      my_cart = current_session_cart

      get cart_url(my_cart)
      expect(response).to be_successful
    end

    it "does not show a cart other than the one in session" do
      current_session_cart

      get cart_url(cart)

      expect(response).to redirect_to(store_index_url)
    end

    it "notifies the system administrator" do
      current_session_cart

      expect {
        get cart_url(cart)
      }.to have_enqueued_mail(SystemMailer, :error_notification)
    end
  end

  describe "GET /carts/:id/edit" do
    it "renders the cart in session successfully" do
      my_cart = current_session_cart

      get edit_cart_url(my_cart)
      expect(response).to be_successful
    end

    it "does not edit a cart other than the one in session" do
      current_session_cart

      get edit_cart_url(cart)

      expect(response).to redirect_to(store_index_url)
    end
  end

  describe "PATCH /carts/:id" do
    it "updates the cart in session and redirects to it" do
      my_cart = current_session_cart

      patch cart_url(my_cart), params: { cart: {} }
      expect(response).to redirect_to(cart_url(my_cart))
    end
  end

  describe "DELETE /carts/:id" do
    it "destroys the current session's cart and redirects to the store" do
      session_cart = current_session_cart

      expect {
        delete cart_url(session_cart)
      }.to change(Cart, :count).by(-1)

      expect(response).to redirect_to(store_index_url)
    end

    it "does not destroy a cart other than the one in session" do
      current_session_cart

      expect {
        delete cart_url(cart)
      }.not_to change(Cart, :count)

      expect(response).to redirect_to(store_index_url)
    end

    context "as a Turbo Stream request" do
      it "empties the cart without redrawing the whole page" do
        session_cart = current_session_cart

        delete cart_url(session_cart), as: :turbo_stream

        expect(response).to be_successful
        expect(response.body).to match(%r{<turbo-stream action="replace" target="cart">})
        expect(response.body).to match(/Your cart is currently empty/)
        expect(response.body).not_to match(/The Pragmatic Programmer/)
      end
    end
  end
end
