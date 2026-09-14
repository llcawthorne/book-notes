class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :cart, optional: true

  def total_price
    price * quantity
  end

  def decrement_quantity!
    if quantity > 1
      decrement!(:quantity)
    else
      destroy!
    end
  end

  def increment_quantity!
    increment!(:quantity)
  end
end
