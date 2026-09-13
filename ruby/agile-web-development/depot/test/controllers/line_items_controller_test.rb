require "test_helper"

class LineItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @line_item = line_items(:one)
    login_as users(:one)
  end

  test "should get index" do
    get line_items_url
    assert_response :success
  end

  test "should get new" do
    get new_line_item_url
    assert_response :success
  end

  test "should create line_item" do
    assert_difference("LineItem.count") do
      post line_items_url, params: { product_id: products(:pragprog).id }
    end

    follow_redirect!

    assert_select "h2", "Your Cart"
    assert_select "td", "The Pragmatic Programmer"
  end

  test "should redirect with a friendly alert when the product no longer exists" do
    assert_no_difference("LineItem.count") do
      post line_items_url, params: { product_id: 0 }
    end

    assert_redirected_to store_index_url
    follow_redirect!
    assert_select "#alert", /no longer available/
  end

  test "should notify the system administrator when the product no longer exists" do
    assert_enqueued_email_with SystemMailer, :error_notification,
      args: [ "Attempt to access invalid product 0" ] do
      post line_items_url, params: { product_id: 0 }
    end
  end

  test "should remove the stale product's frame via turbo-stream instead of leaving it blank" do
    post line_items_url, params: { product_id: 0 }, as: :turbo_stream

    assert_response :success
    assert_match(/<turbo-stream action="remove" target="product_0">/, @response.body)
    assert_match(/no longer available/, @response.body)
  end

  test "should create line_item via turbo-stream" do
    assert_difference("LineItem.count") do
      post line_items_url, params: { product_id: products(:pragprog).id },
        as: :turbo_stream
    end

    assert_response :success
    assert_match /<tr class="line-item-highlight"/, @response.body
  end

  test "should show line_item" do
    get line_item_url(@line_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_line_item_url(@line_item)
    assert_response :success
  end

  test "should update line_item" do
    patch line_item_url(@line_item),
      params: { line_item: { product_id: @line_item.product_id } }
    assert_redirected_to line_item_url(@line_item)
  end

  test "should destroy line_item" do
    assert_difference("LineItem.count", -1) do
      delete line_item_url(@line_item)
    end

    assert_redirected_to line_items_url
  end

  test "should let an unauthenticated visitor remove a line item from their own cart" do
    delete session_url
    post line_items_url, params: { product_id: products(:pragprog).id }
    line_item = LineItem.last

    assert_difference("LineItem.count", -1) do
      delete line_item_url(line_item)
    end

    assert_redirected_to store_index_url
  end

  test "should remove a line item via turbo-stream and update the cart total" do
    delete session_url
    post line_items_url, params: { product_id: products(:two).id }
    removed_item = LineItem.last
    post line_items_url, params: { product_id: products(:pragprog).id }

    delete line_item_url(removed_item), as: :turbo_stream

    assert_response :success
    assert_match /<turbo-stream action="remove" target="line_item_#{removed_item.id}">/, @response.body
    assert_match(/\$39\.99/, @response.body)
    assert_no_match(/\$9\.99/, @response.body)
  end

  test "should forbid an unauthenticated visitor from removing a line item outside their own cart" do
    delete session_url
    post line_items_url, params: { product_id: products(:pragprog).id }

    assert_no_difference("LineItem.count") do
      delete line_item_url(@line_item)
    end

    assert_response :forbidden
  end

  test "should let an unauthenticated visitor decrement a line item's quantity" do
    delete session_url
    post line_items_url, params: { product_id: products(:pragprog).id }
    post line_items_url, params: { product_id: products(:pragprog).id }
    my_item = LineItem.last

    assert_difference -> { my_item.reload.quantity }, -1 do
      patch decrement_line_item_url(my_item)
    end

    assert_redirected_to store_index_url
  end

  test "should destroy the line item once decrementing reaches zero" do
    delete session_url
    post line_items_url, params: { product_id: products(:pragprog).id }
    my_item = LineItem.last

    assert_difference("LineItem.count", -1) do
      patch decrement_line_item_url(my_item)
    end
  end

  test "should replace the row via turbo-stream when decrementing" do
    delete session_url
    post line_items_url, params: { product_id: products(:pragprog).id }
    post line_items_url, params: { product_id: products(:pragprog).id }
    my_item = LineItem.last

    patch decrement_line_item_url(my_item), as: :turbo_stream

    assert_response :success
    assert_match /<turbo-stream action="replace" target="line_item_#{my_item.id}">/, @response.body
    assert_match(/\$39\.99/, @response.body)
  end

  test "should remove the row via turbo-stream once decrementing reaches zero" do
    delete session_url
    post line_items_url, params: { product_id: products(:pragprog).id }
    my_item = LineItem.last

    patch decrement_line_item_url(my_item), as: :turbo_stream

    assert_response :success
    assert_match /<turbo-stream action="remove" target="line_item_#{my_item.id}">/, @response.body
  end

  test "should forbid an unauthenticated visitor from decrementing a line item outside their own cart" do
    delete session_url
    post line_items_url, params: { product_id: products(:pragprog).id }

    assert_no_difference -> { @line_item.reload.quantity } do
      patch decrement_line_item_url(@line_item)
    end

    assert_response :forbidden
  end
end
