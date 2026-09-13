require "rails_helper"

RSpec.describe "Orders", type: :request do
  fixtures :orders, :users, :products

  before { login_as users(:one) }

  let(:order) { orders(:one) }

  describe "GET /orders" do
    it "renders successfully" do
      get orders_url
      expect(response).to be_successful
    end
  end

  describe "GET /orders/new" do
    context "with an empty cart" do
      it "redirects to the store with a notice" do
        get new_order_url

        expect(response).to redirect_to(store_index_path)
        expect(flash[:notice]).to eq("Your cart is empty")
      end
    end

    context "with an item in the cart" do
      before { post line_items_url, params: { product_id: products(:pragprog).id } }

      it "renders successfully" do
        get new_order_url
        expect(response).to be_successful
      end
    end
  end

  describe "POST /orders" do
    it "creates an order and redirects to the store" do
      expect {
        post orders_url, params: { order: {
          address: order.address, email: order.email, name: order.name, pay_type: order.pay_type
        } }
      }.to change(Order, :count).by(1)

      expect(response).to redirect_to(store_index_url(locale: "en"))
    end
  end

  describe "GET /orders/:id" do
    it "renders successfully" do
      get order_url(order)
      expect(response).to be_successful
    end
  end

  describe "GET /orders/:id/edit" do
    it "renders successfully" do
      get edit_order_url(order)
      expect(response).to be_successful
    end
  end

  describe "PATCH /orders/:id" do
    it "updates the order and redirects to it" do
      patch order_url(order), params: { order: {
        address: order.address, email: order.email, name: order.name, pay_type: order.pay_type
      } }

      expect(response).to redirect_to(order_url(order))
    end

    context "when ship_date is set" do
      it "sends a shipped notification" do
        expect {
          patch order_url(order), params: { order: {
            address: order.address, email: order.email, name: order.name, pay_type: order.pay_type,
            ship_date: Date.current
          } }
        }.to have_enqueued_mail(OrderMailer, :shipped).with(order)
      end
    end

    context "when ship_date is not part of the update" do
      it "does not send a notification" do
        expect {
          patch order_url(order), params: { order: {
            address: order.address, email: order.email, name: order.name, pay_type: order.pay_type
          } }
        }.not_to have_enqueued_mail(OrderMailer, :shipped)
      end
    end

    context "when ship_date is cleared" do
      it "does not send a notification" do
        order.update!(ship_date: Date.current)

        expect {
          patch order_url(order), params: { order: {
            address: order.address, email: order.email, name: order.name, pay_type: order.pay_type,
            ship_date: ""
          } }
        }.not_to have_enqueued_mail(OrderMailer, :shipped)
      end
    end
  end

  describe "DELETE /orders/:id" do
    it "destroys the order and redirects to the index" do
      expect {
        delete order_url(order)
      }.to change(Order, :count).by(-1)

      expect(response).to redirect_to(orders_url)
    end
  end
end
