require "rails_helper"

RSpec.describe "Coupons", type: :request do
  fixtures :all

  before { login_as users(:one) }

  let!(:coupon) { Coupon.create!(code: "SAVE10", discount_percent: 10) }

  describe "GET /coupons" do
    it "renders successfully" do
      get coupons_url
      expect(response).to be_successful
    end
  end

  describe "GET /coupons/new" do
    it "renders successfully" do
      get new_coupon_url
      expect(response).to be_successful
    end
  end

  describe "POST /coupons" do
    it "creates a coupon and redirects to the list" do
      expect {
        post coupons_url, params: { coupon: { code: "SAVE20", discount_percent: 20 } }
      }.to change(Coupon, :count).by(1)

      expect(response).to redirect_to(coupons_url)
    end

    it "creates a coupon with an expiration date" do
      post coupons_url, params: { coupon: { code: "SAVE20", discount_percent: 20, expires_on: Date.tomorrow } }

      expect(Coupon.find_by(code: "SAVE20").expires_on).to eq(Date.tomorrow)
    end

    it "does not create an invalid coupon" do
      expect {
        post coupons_url, params: { coupon: { code: "", discount_percent: 20 } }
      }.not_to change(Coupon, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /coupons/:id" do
    it "destroys the coupon and redirects to the list" do
      expect {
        delete coupon_url(coupon)
      }.to change(Coupon, :count).by(-1)

      expect(response).to redirect_to(coupons_url)
    end
  end

  describe "without being signed in" do
    before { logout }

    it "requires authentication to list coupons" do
      get coupons_url
      expect(response).to redirect_to(new_session_url)
    end

    it "requires authentication to create a coupon" do
      expect {
        post coupons_url, params: { coupon: { code: "SAVE20", discount_percent: 20 } }
      }.not_to change(Coupon, :count)

      expect(response).to redirect_to(new_session_url)
    end

    it "requires authentication to destroy a coupon" do
      expect {
        delete coupon_url(coupon)
      }.not_to change(Coupon, :count)

      expect(response).to redirect_to(new_session_url)
    end
  end
end
