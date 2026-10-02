require "rails_helper"

RSpec.describe "LineItems", type: :request do
  fixtures :all

  before { login_as users(:one) }

  let(:line_item) { line_items(:one) }

  describe "GET /line_items" do
    it "renders successfully" do
      get line_items_url
      expect(response).to be_successful
    end
  end

  describe "GET /line_items/new" do
    it "renders successfully" do
      get new_line_item_url
      expect(response).to be_successful
    end
  end

  describe "POST /line_items" do
    context "as an HTML request" do
      it "adds the product to the cart and redirects there" do
        expect {
          post line_items_url, params: { product_id: products(:pragprog).id }
        }.to change(LineItem, :count).by(1)

        follow_redirect!

        assert_select "h2", "Your Cart"
        assert_select "td", "The Pragmatic Programmer"
      end
    end

    context "as a Turbo Stream request" do
      it "adds the product and highlights the new line item" do
        expect {
          post line_items_url, params: { product_id: products(:pragprog).id }, as: :turbo_stream
        }.to change(LineItem, :count).by(1)

        expect(response).to be_successful
        expect(response.body).to match(/<tr class="line-item-highlight"/)
      end
    end

    context "when the product no longer exists" do
      it "redirects to the store with a friendly alert instead of crashing" do
        expect {
          post line_items_url, params: { product_id: 0 }
        }.not_to change(LineItem, :count)

        expect(response).to redirect_to(store_index_url)
        follow_redirect!
        expect(response.body).to match(/no longer available/)
      end

      it "notifies the system administrator" do
        expect {
          post line_items_url, params: { product_id: 0 }
        }.to have_enqueued_mail(SystemMailer, :error_notification)
      end

      it "removes the stale product's frame via turbo-stream instead of leaving it blank" do
        post line_items_url, params: { product_id: 0 }, as: :turbo_stream

        expect(response).to be_successful
        expect(response.body).to match(%r{<turbo-stream action="remove" target="product_0">})
        expect(response.body).to match(/no longer available/)
      end
    end
  end

  describe "GET /line_items/:id" do
    it "renders successfully" do
      get line_item_url(line_item)
      expect(response).to be_successful
    end
  end

  describe "GET /line_items/:id/edit" do
    it "renders successfully" do
      get edit_line_item_url(line_item)
      expect(response).to be_successful
    end
  end

  describe "PATCH /line_items/:id" do
    it "updates the line item and redirects to it" do
      patch line_item_url(line_item), params: { line_item: { product_id: line_item.product_id } }
      expect(response).to redirect_to(line_item_url(line_item))
    end
  end

  describe "DELETE /line_items/:id" do
    it "destroys the line item and redirects to the index" do
      expect {
        delete line_item_url(line_item)
      }.to change(LineItem, :count).by(-1)

      expect(response).to redirect_to(line_items_url)
    end

    context "as an unauthenticated visitor" do
      before { logout }

      it "removes a line item from their own cart and redirects to the store" do
        post line_items_url, params: { product_id: products(:pragprog).id }
        my_item = LineItem.last

        expect {
          delete line_item_url(my_item)
        }.to change(LineItem, :count).by(-1)

        expect(response).to redirect_to(store_index_url)
      end

      it "removes a line item via turbo-stream and updates the cart total" do
        post line_items_url, params: { product_id: products(:two).id }
        removed_item = LineItem.last
        post line_items_url, params: { product_id: products(:pragprog).id }

        delete line_item_url(removed_item), as: :turbo_stream

        expect(response).to be_successful
        expect(response.body).to match(%r{<turbo-stream action="remove" target="line_item_#{removed_item.id}">})
        expect(response.body).to match(/\$39\.99/)
        expect(response.body).not_to match(/\$9\.99/)
      end

      it "is forbidden from removing a line item outside their own cart" do
        post line_items_url, params: { product_id: products(:pragprog).id }

        expect {
          delete line_item_url(line_item)
        }.not_to change(LineItem, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /line_items/:id/decrement" do
    context "as an unauthenticated visitor" do
      before { logout }

      it "reduces the quantity by one and redirects to the store" do
        post line_items_url, params: { product_id: products(:pragprog).id }
        post line_items_url, params: { product_id: products(:pragprog).id }
        my_item = LineItem.last

        expect {
          patch decrement_line_item_url(my_item)
        }.to change { my_item.reload.quantity }.from(2).to(1)

        expect(response).to redirect_to(store_index_url)
      end

      it "removes the line item once the quantity reaches zero" do
        post line_items_url, params: { product_id: products(:pragprog).id }
        my_item = LineItem.last

        expect {
          patch decrement_line_item_url(my_item)
        }.to change(LineItem, :count).by(-1)
      end

      it "replaces the row via turbo-stream and updates the cart total" do
        post line_items_url, params: { product_id: products(:pragprog).id }
        post line_items_url, params: { product_id: products(:pragprog).id }
        my_item = LineItem.last

        patch decrement_line_item_url(my_item), as: :turbo_stream

        expect(response).to be_successful
        expect(response.body).to match(%r{<turbo-stream action="replace" target="line_item_#{my_item.id}">})
        expect(response.body).to match(/\$39\.99/)
      end

      it "removes the row via turbo-stream once the quantity reaches zero" do
        post line_items_url, params: { product_id: products(:pragprog).id }
        my_item = LineItem.last

        patch decrement_line_item_url(my_item), as: :turbo_stream

        expect(response).to be_successful
        expect(response.body).to match(%r{<turbo-stream action="remove" target="line_item_#{my_item.id}">})
      end

      it "is forbidden from decrementing a line item outside their own cart" do
        post line_items_url, params: { product_id: products(:pragprog).id }

        expect {
          patch decrement_line_item_url(line_item)
        }.not_to change { line_item.reload.quantity }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /line_items/:id/increment" do
    context "as an unauthenticated visitor" do
      before { logout }

      it "increases the quantity by one and redirects to the store" do
        post line_items_url, params: { product_id: products(:pragprog).id }
        my_item = LineItem.last

        expect {
          patch increment_line_item_url(my_item)
        }.to change { my_item.reload.quantity }.from(1).to(2)

        expect(response).to redirect_to(store_index_url)
      end

      it "replaces the row via turbo-stream and updates the cart total" do
        post line_items_url, params: { product_id: products(:pragprog).id }
        my_item = LineItem.last

        patch increment_line_item_url(my_item), as: :turbo_stream

        expect(response).to be_successful
        expect(response.body).to match(%r{<turbo-stream action="replace" target="line_item_#{my_item.id}">})
        expect(response.body).to match(/\$79\.98/)
      end

      it "is forbidden from incrementing a line item outside their own cart" do
        post line_items_url, params: { product_id: products(:pragprog).id }

        expect {
          patch increment_line_item_url(line_item)
        }.not_to change { line_item.reload.quantity }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
