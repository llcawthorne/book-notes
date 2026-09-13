require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "add_product captures the product's current price on the line item" do
    cart = carts(:one)
    product = products(:pragprog)

    line_item = cart.add_product(product)

    assert_equal product.price, line_item.price
  end

  test "add_product keeps the originally captured price after the product's price changes" do
    cart = carts(:one)
    product = products(:pragprog)

    line_item = cart.add_product(product)
    line_item.save!
    original_price = line_item.price

    product.update!(price: original_price + 10)
    line_item.reload

    assert_equal original_price, line_item.price
    assert_not_equal product.price, line_item.price
  end

  test "add_product increments quantity without touching the captured price" do
    cart = carts(:one)
    product = products(:pragprog)

    first_item = cart.add_product(product)
    first_item.save!

    same_item = cart.add_product(product)

    assert_equal first_item.id, same_item.id
    assert_equal 2, same_item.quantity
    assert_equal first_item.price, same_item.price
  end
end
