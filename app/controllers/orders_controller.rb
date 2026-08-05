class OrdersController < ApplicationController
  before_action :authenticate_customer!

  def index
    @categories = Category.order(:name)
     @orders = current_customer.orders
                              .includes(order_items: :product)
                              .order(created_at: :desc)
  end

  def show
    @categories = Category.order(:name)
       @order = current_customer.orders
                             .includes(order_items: :product)
                             .find(params[:id])
  end



  def create
    cart = current_cart

    if cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end
    province = current_customer.province

    unless province
    redirect_to edit_customer_profile_path,
                alert: "Please select a province before checkout."
    return
    end

    subtotal = cart.total_price.to_d


    gst = subtotal * (province.gst_rate.to_d / 100)
    pst = subtotal * (province.pst_rate.to_d / 100)
    hst = subtotal * (province.hst_rate.to_d / 100)
    total_tax = gst + pst + hst

    total = (subtotal + total_tax).round(2)
    order = nil

    ActiveRecord::Base.transaction do
      order = current_customer.orders.create!(
        status: "placed",
        shipping_address: formatted_shipping_address,
        subtotal: subtotal,
        tax: total_tax,
        total: total
      )

      cart.cart_items.includes(:product).each do |cart_item|
        product = cart_item.product

        if cart_item.quantity > product.stock_quanity
          raise ActiveRecord::Rollback,
                "Not enough stock available for #{product.name}."
        end
        order.order_items.create!(
          product: product,
          product_name: product.name,
          quantity: cart_item.quantity,
          unit_price: product.product_price,
        )

        product.update!(
          stock_quanity: product.stock_quanity - cart_item.quantity
        )
      end

      cart.cart_items.destroy_all
    end

    if order&.persisted?
      redirect_to order_path(order),
                  notice: "Your order was created successfully."
    else
      redirect_to cart_path,
                  alert: "The order could not be completed."
    end
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
