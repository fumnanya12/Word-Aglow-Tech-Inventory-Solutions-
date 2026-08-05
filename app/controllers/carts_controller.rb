class CartsController < ApplicationController
  def show
     @cart = current_cart
    @cart_items = @cart.cart_items.includes(:product)
    @categories = Category.order(:name)
    # @products = Product.includes(:category).limit(12).page(params[:page]).per(12)
  end
end
