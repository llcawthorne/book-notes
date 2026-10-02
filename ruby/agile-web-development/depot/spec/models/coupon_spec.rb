require "rails_helper"

RSpec.describe Coupon, type: :model do
  subject(:coupon) { Coupon.new(code: "SAVE10", discount_percent: 10) }

  it { is_expected.to be_valid }

  it "requires a code" do
    coupon.code = nil

    expect(coupon).to be_invalid
    expect(coupon.errors[:code]).to be_present
  end

  it "requires a discount percent between 1 and 100" do
    coupon.discount_percent = 0
    expect(coupon).to be_invalid

    coupon.discount_percent = 101
    expect(coupon).to be_invalid

    coupon.discount_percent = 10
    expect(coupon).to be_valid
  end

  it "normalizes the code to a stripped, upcased form" do
    coupon.code = "  save10  "
    coupon.save!

    expect(coupon.code).to eq("SAVE10")
  end

  it "rejects a duplicate code regardless of case or whitespace" do
    coupon.save!

    duplicate = Coupon.new(code: " save10 ", discount_percent: 20)

    expect(duplicate).to be_invalid
    expect(duplicate.errors[:code]).to be_present
  end

  describe "#expired?" do
    it "is not expired when expires_on is blank" do
      expect(coupon).not_to be_expired
    end

    it "is not expired when expires_on is today or in the future" do
      coupon.expires_on = Date.current
      expect(coupon).not_to be_expired

      coupon.expires_on = Date.tomorrow
      expect(coupon).not_to be_expired
    end

    it "is expired when expires_on is in the past" do
      coupon.expires_on = Date.yesterday
      expect(coupon).to be_expired
    end
  end
end
