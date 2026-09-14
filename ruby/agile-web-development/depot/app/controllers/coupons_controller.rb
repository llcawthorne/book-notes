class CouponsController < ApplicationController
  before_action :set_coupon, only: %i[ destroy ]

  # GET /coupons
  def index
    @coupons = Coupon.all
  end

  # GET /coupons/new
  def new
    @coupon = Coupon.new
  end

  # POST /coupons
  def create
    @coupon = Coupon.new(coupon_params)

    if @coupon.save
      redirect_to coupons_path, notice: "Coupon was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # DELETE /coupons/1
  def destroy
    @coupon.destroy!
    redirect_to coupons_path, notice: "Coupon was successfully destroyed.", status: :see_other
  end

  private
    def set_coupon
      @coupon = Coupon.find(params.expect(:id))
    end

    def coupon_params
      params.expect(coupon: [ :code, :discount_percent ])
    end
end
