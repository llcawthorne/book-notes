#---
# Excerpted from "Agile Web Development with Rails 8",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/rails8 for more book information.
#---
require "application_system_test_case"

class CartsTest < ApplicationSystemTestCase
  setup do
    @cart = carts(:one)
  end

  test "visiting the index" do
    visit carts_url
    assert_selector "h1", text: "Carts"
  end

  test "should create cart" do
    visit carts_url
    click_on "New cart"

    click_on "Create Cart"

    assert_text "Cart was successfully created"
    click_on "Back"
  end

  test "should update Cart" do
    visit cart_url(@cart)
    click_on "Edit this cart", match: :first

    click_on "Update Cart"

    assert_text "Cart was successfully updated"
    click_on "Back"
  end

  test "should destroy Cart" do
    visit cart_url(@cart)
    accept_confirm { click_on "Destroy this cart", match: :first }

    assert_text "Cart was successfully destroyed"
  end
end
