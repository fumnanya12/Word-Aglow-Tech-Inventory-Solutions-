class CheckoutsController < ApplicationController
   before_action :authenticate_customer!
  before_action :set_cart

  def show
    @categories = Category.order(:name)

    redirect_to cart_path, alert: "Your cart is empty." and return if @cart.cart_items.empty?

    unless current_customer.province
      redirect_to edit_customer_profile_path,
                  alert: "Please add your province before checkout."
      return
    end

    calculate_totals
  end

  def create
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end

    unless current_customer.province
      redirect_to edit_customer_profile_path,
                  alert: "Please add your province before checkout."
      return
    end

    unavailable_item = @cart.cart_items.includes(:product).find do |item|
      item.quantity > item.product.stock_quanity
    end

    if unavailable_item
      redirect_to cart_path,
                  alert: "Only #{unavailable_item.product.stock_quanity} " \
                         "#{unavailable_item.product.name} are available."
      return
    end

    calculate_totals

    order = ActiveRecord::Base.transaction do
      new_order = current_customer.orders.create!(
        status: "placed",
        placed_at: Time.current,
        shipping_address: formatted_shipping_address,
        subtotal: @subtotal,
        tax: @tax,
        total: @total
      )

      @cart.cart_items.includes(:product).each do |cart_item|
        product = cart_item.product

        new_order.order_items.create!(
          product: product,
          product_name: product.name,
          quantity: cart_item.quantity,
          unit_price: product.product_price
        )

        product.update!(
          stock_quanity: product.stock_quanity - cart_item.quantity
        )
      end

      @cart.cart_items.destroy_all

      new_order
  end
redirect_to order_path(order),
                notice: "Your order was placed successfully."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to checkout_path,
                alert: "Checkout failed: #{error.record.errors.full_messages.to_sentence}"
  end

  private

  def set_cart
    @cart = current_cart
  end

  def calculate_totals
    @subtotal = @cart.total_price

    province = current_customer.province

    gst_rate = province.gst_rate.to_d
    pst_rate = province.pst_rate.to_d
    hst_rate = province.hst_rate.to_d
    @gst_amount = (@subtotal * gst_rate).round(2)
  @pst_amount = (@subtotal * pst_rate).round(2)
  @hst_amount = (@subtotal * hst_rate).round(2)

    combined_tax_rate = gst_rate + pst_rate + hst_rate

    @tax = (@subtotal * combined_tax_rate).round(2)
    @total = @subtotal + @tax
  end

  def formatted_shipping_address
    [
      "#{current_customer.first_name} #{current_customer.last_name}",
      current_customer.address_line_one,
      current_customer.address_line_two,
      current_customer.city,
      current_customer.province.name,
      current_customer.postal_code,
      current_customer.country
    ].compact_blank.join(", ")
  end
end
