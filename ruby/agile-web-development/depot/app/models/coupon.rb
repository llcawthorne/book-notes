class Coupon < ApplicationRecord
  before_validation { self.code = code.to_s.strip.upcase }

  validates :code, presence: true, uniqueness: true
  validates :discount_percent,
    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }

  # expires_on is optional -- a coupon with none set never expires.
  def expired?
    expires_on.present? && expires_on < Date.current
  end
end
