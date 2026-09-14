require "pago"

class Order < ApplicationRecord
  has_many :line_items, dependent: :destroy
  has_many :support_requests, dependent: :nullify
  enum :pay_type, {
    "Check"          => 0,
    "Credit card"    => 1,
    "Purchase order" => 2
  }
  validates :name, :address, :email, presence: true
  validates :pay_type, inclusion: pay_types.keys

  # Not a column -- an admin-issued code entered at checkout, resolved to a
  # discount_percent (below) at validation time. discount_percent, not a
  # live reference to the Coupon, is what's actually persisted, so a coupon
  # edited or deleted later doesn't change what a past order actually paid.
  attr_accessor :coupon_code

  before_validation :apply_coupon_code

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      line_items << item
    end
  end

  def subtotal
    line_items.sum(&:total_price)
  end

  def discount_amount
    subtotal * discount_percent / 100.0
  end

  def total_price
    subtotal - discount_amount
  end

  def charge!(pay_type_params)
    payment_details = {}
    payment_method = nil

    case pay_type
    when "Check"
      payment_method = :check
      payment_details[:routing] = pay_type_params[:routing_number]
      payment_details[:account] = pay_type_params[:account_number]
    when "Credit card"
      payment_method = :credit_card
      month, year = pay_type_params[:expiration_date].split("/")
      payment_details[:cc_num] = pay_type_params[:credit_card_number]
      payment_details[:expiration_month] = month
      payment_details[:expiration_year] = year
    when "Purchase order"
      payment_method = :po
      payment_details[:po_num] = pay_type_params[:po_number]
    end

    payment_result = Pago.make_payment(
      order_id: id,
      payment_method: payment_method,
      payment_details: payment_details
    )

    if payment_result.succeeded?
      OrderMailer.received(self).deliver_later
    else
      OrderMailer.payment_failed(self, payment_result.error).deliver_later
    end
  end

  private
    def apply_coupon_code
      return if coupon_code.blank?

      coupon = Coupon.find_by(code: coupon_code.to_s.strip.upcase)

      if coupon
        self.discount_percent = coupon.discount_percent
      else
        errors.add(:coupon_code, "is not a valid coupon code")
      end
    end
end
