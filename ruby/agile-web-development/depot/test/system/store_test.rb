require "application_system_test_case"

class StoreTest < ApplicationSystemTestCase
  test "highlights the line item just added to the cart" do
    product = products(:pragprog)
    dom_id = ActionView::RecordIdentifier.dom_id(product)

    visit store_index_url
    within("##{dom_id}") { click_on "Add to Cart", match: :first }

    assert_selector "tr.line-item-highlight", text: product.title
  end

  test "adding an item reveals the cart and emptying it hides the cart again" do
    visit store_index_url

    assert_no_text "Your Cart"

    click_on "Add to Cart", match: :first

    assert_text "Your Cart"
    assert_button "Empty cart"

    click_on "Empty cart"

    assert_no_text "Your Cart"
  end
end
