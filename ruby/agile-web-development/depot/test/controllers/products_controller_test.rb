require "test_helper"
require "turbo/broadcastable/test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  setup do
    @product = products(:one)
    @title = "The Great Book #{rand(1000)}"
    login_as users(:one)
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: {
        product: {
          description_translations: { en: @product.description },
          image: file_fixture_upload("lorem.jpg", "image/jpeg"),
          price: @product.price,
          title: @title
        }
      }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: {
      product: {
        description_translations: { en: @product.description },
        image: file_fixture_upload("lorem.jpg", "image/jpeg"),
        price: @product.price,
        title: @title
      }
    }
    assert_redirected_to product_url(@product)
  end

  test "should broadcast a replace of the product's card to the store catalog when updated" do
    turbo_streams = capture_turbo_stream_broadcasts "store/products" do
      perform_enqueued_jobs do
        patch product_url(@product), params: {
          product: {
            description_translations: { en: @product.description },
            image: file_fixture_upload("lorem.jpg", "image/jpeg"),
            price: @product.price,
            title: @title
          }
        }
      end
    end

    assert_equal 1, turbo_streams.size
    assert_equal "replace", turbo_streams.first["action"]
    assert_equal ActionView::RecordIdentifier.dom_id(@product), turbo_streams.first["target"]
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end

  test "should not destroy a product referenced by line items" do
    assert_no_difference("Product.count") do
      delete product_url(products(:two))
    end

    assert_redirected_to products_url
    follow_redirect!
    assert_select "#alert", /Line Items present/
    assert Product.exists?(products(:two).id)
  end

  test "should require authentication to list products" do
    logout

    get products_url
    assert_redirected_to new_session_url
  end

  test "should require authentication to update a product" do
    logout

    patch product_url(@product), params: { product: { title: "Hijacked Title" } }
    assert_redirected_to new_session_url
    assert_not_equal "Hijacked Title", @product.reload.title
  end

  test "should require authentication to destroy a product" do
    logout

    assert_no_difference("Product.count") do
      delete product_url(@product)
    end
    assert_redirected_to new_session_url
  end
end
