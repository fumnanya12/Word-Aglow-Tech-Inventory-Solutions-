class CartItemsController < ApplicationController
  before_action :set_cart_item, only: [ :update, :destroy ]

  def create
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    if quantity < 1
      redirect_to product_path(product),
                  alert: "Quantity must be at least 1."
      return
    end

    if quantity > product.stock_quanity
      redirect_to product_path(product),
                  alert: "The requested quantity is not available."
      return
    end

    cart_item = current_cart.cart_items.find_or_initialize_by(
      product: product
    )

    cart_item.quantity ||= 0
    new_quantity = cart_item.quantity + quantity

    if new_quantity > product.stock_quanity
      redirect_to product_path(product),
                  alert: "You cannot add more than the available stock."
      return
    end

    cart_item.quantity = new_quantity
    cart_item.save!

    redirect_to cart_path,
                notice: "#{product.name} was added to your cart."
  end

  def update
    quantity = params[:quantity].to_i
    product = @cart_item.product

    if quantity < 1
      @cart_item.destroy

      redirect_to cart_path,
                  notice: "#{product.name} was removed from your cart."
      return
    end

    if quantity > product.stock_quanity
      redirect_to cart_path,
                  alert: "Only #{product.stock_quanity} are available."
      return
    end

    @cart_item.update!(quantity: quantity)

    redirect_to cart_path,
                notice: "Cart quantity was updated."
  end

  def destroy
    product_name = @cart_item.product.name
    @cart_item.destroy

    redirect_to cart_path,
                notice: "#{product_name} was removed from your cart."
  end

  private

  def set_cart_item
    @cart_item = current_cart.cart_items.find(params[:id])
  end
end
