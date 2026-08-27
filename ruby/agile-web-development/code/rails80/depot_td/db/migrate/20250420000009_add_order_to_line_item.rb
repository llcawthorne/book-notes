#---
# Excerpted from "Agile Web Development with Rails 8",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/rails8 for more book information.
#---
class AddOrderToLineItem < ActiveRecord::Migration[8.0]
  def change
    add_reference :line_items, :order, null: true, foreign_key: true
    change_column :line_items, :cart_id, :integer, null: true
  end
end
