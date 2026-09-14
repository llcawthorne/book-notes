class AddDiscountPercentToOrders < ActiveRecord::Migration[8.0]
  def change
    # Captured at order time, like line_items.price captures the product's
    # price at time of purchase -- so a later coupon edit/deletion doesn't
    # change what a historical order actually paid.
    add_column :orders, :discount_percent, :integer, null: false, default: 0
  end
end
