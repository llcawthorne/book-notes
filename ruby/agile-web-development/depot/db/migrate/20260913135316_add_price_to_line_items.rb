class AddPriceToLineItems < ActiveRecord::Migration[8.0]
  def change
    add_column :line_items, :price, :decimal, precision: 8, scale: 2
  end
end
