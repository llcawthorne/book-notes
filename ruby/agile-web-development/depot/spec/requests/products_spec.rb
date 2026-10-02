require "rails_helper"
require "turbo/broadcastable/test_helper"

RSpec.describe "Products", type: :request do
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  fixtures :all

  before { login_as users(:one) }

  let(:product) { products(:one) }
  let(:title) { "The Great Book #{rand(1000)}" }

  def uploaded_image(filename: "lorem.jpg", content_type: "image/jpeg")
    Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/files", filename), content_type)
  end

  describe "GET /products" do
    it "renders successfully" do
      get products_url
      expect(response).to be_successful
    end
  end

  describe "GET /products/new" do
    it "renders successfully" do
      get new_product_url
      expect(response).to be_successful
    end
  end

  describe "POST /products" do
    it "creates a product and redirects to it" do
      expect {
        post products_url, params: { product: {
          description_translations: { en: product.description },
          image: uploaded_image,
          price: product.price,
          title: title
        } }
      }.to change(Product, :count).by(1)

      expect(response).to redirect_to(product_url(Product.last))
    end
  end

  describe "GET /products/:id" do
    it "renders successfully" do
      get product_url(product)
      expect(response).to be_successful
    end
  end

  describe "GET /products/:id/edit" do
    it "renders successfully" do
      get edit_product_url(product)
      expect(response).to be_successful
    end
  end

  describe "PATCH /products/:id" do
    it "updates the product and redirects to it" do
      patch product_url(product), params: { product: {
        description_translations: { en: product.description },
        image: uploaded_image,
        price: product.price,
        title: title
      } }

      expect(response).to redirect_to(product_url(product))
    end

    it "broadcasts a replace of the product's card to the store catalog" do
      turbo_streams = capture_turbo_stream_broadcasts "store/products" do
        perform_enqueued_jobs do
          patch product_url(product), params: { product: {
            description_translations: { en: product.description },
            image: uploaded_image,
            price: product.price,
            title: title
          } }
        end
      end

      expect(turbo_streams.size).to eq(1)
      expect(turbo_streams.first["action"]).to eq("replace")
      expect(turbo_streams.first["target"]).to eq(ActionView::RecordIdentifier.dom_id(product))
    end
  end

  describe "DELETE /products/:id" do
    context "when the product has no line items" do
      it "destroys the product and redirects to the index" do
        expect {
          delete product_url(product)
        }.to change(Product, :count).by(-1)

        expect(response).to redirect_to(products_url)
      end
    end

    context "when the product is referenced by a line item" do
      it "does not destroy it and shows a friendly alert instead of crashing" do
        expect {
          delete product_url(products(:two))
        }.not_to change(Product, :count)

        expect(response).to redirect_to(products_url)
        follow_redirect!
        expect(response.body).to match(/Line Items present/)
      end
    end
  end

  describe "without being signed in" do
    before { logout }

    it "requires authentication to list products" do
      get products_url

      expect(response).to redirect_to(new_session_url)
    end

    it "requires authentication to update a product" do
      patch product_url(product), params: { product: { title: "Hijacked Title" } }

      expect(response).to redirect_to(new_session_url)
      expect(product.reload.title).not_to eq("Hijacked Title")
    end

    it "requires authentication to destroy a product" do
      expect {
        delete product_url(product)
      }.not_to change(Product, :count)

      expect(response).to redirect_to(new_session_url)
    end
  end
end
