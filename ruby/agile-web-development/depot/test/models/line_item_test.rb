require "test_helper"

class LineItemTest < ActiveSupport::TestCase
  test "total_price uses the captured price rather than the product's current price" do
    line_item = line_items(:two)
    product = line_item.product

    product.update!(price: line_item.price + 100)

    assert_equal line_item.price * line_item.quantity, line_item.total_price
    assert_not_equal product.price * line_item.quantity, line_item.total_price
  end

  test "decrement_quantity! reduces the quantity by one when more than one remains" do
    line_item = line_items(:two)
    line_item.update!(quantity: 3)

    line_item.decrement_quantity!

    assert_equal 2, line_item.quantity
    assert line_item.persisted?
  end

  test "decrement_quantity! destroys the line item once the quantity would reach zero" do
    line_item = line_items(:two)
    line_item.update!(quantity: 1)

    line_item.decrement_quantity!

    assert line_item.destroyed?
    assert_not LineItem.exists?(line_item.id)
  end
end
