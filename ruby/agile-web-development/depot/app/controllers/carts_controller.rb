class CartsController < ApplicationController
  allow_unauthenticated_access only: %i[ create update destroy ]
  before_action :set_cart, only: %i[ show edit update destroy ]
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_cart

  # GET /carts or /carts.json
  def index
    @carts = Cart.where(id: session[:cart_id])
  end

  # GET /carts/1 or /carts/1.json
  def show
  end

  # GET /carts/new
  def new
    @cart = Cart.new
  end

  # GET /carts/1/edit
  def edit
  end

  # POST /carts or /carts.json
  def create
    @cart = Cart.new(cart_params)

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: "Cart was successfully created." }
        format.json { render :show, status: :created, location: @cart }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @cart.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /carts/1 or /carts/1.json
  def update
    respond_to do |format|
      if @cart.update(cart_params)
        format.html { redirect_to @cart, notice: "Cart was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @cart }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @cart.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /carts/1 or /carts/1.json
  def destroy
    @cart.destroy!
    @cart = nil
    session[:cart_id] = nil

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = t(".empty_notice") }
      format.html { redirect_to store_index_path, status: :see_other,
        notice: t(".empty_notice") }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # Scoped to the cart in the current session so a visitor can't view,
    # edit, or destroy another visitor's cart by guessing its id.
    def set_cart
      @cart = Cart.where(id: session[:cart_id]).find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def cart_params
      params.fetch(:cart, {})
    end

    def invalid_cart
      notify_admin_of_error("Attempt to access invalid cart #{params[:id]}")
      redirect_to store_index_url, notice: "Invalid cart"
    end
end
