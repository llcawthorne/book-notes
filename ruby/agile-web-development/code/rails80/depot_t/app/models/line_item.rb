#---
# Excerpted from "Agile Web Development with Rails 8",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/rails8 for more book information.
#---
class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :cart, optional: true

  def total_price
    price * quantity
  end
end
