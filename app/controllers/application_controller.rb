class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters,
                if: :devise_controller?

  protected

  def configure_permitted_parameters
    customer_fields = [
      :username,
      :first_name,
      :last_name,
      :address_line_one,
      :address_line_two,
      :city,
      :province_id,
      :postal_code,
      :country
    ]

    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: customer_fields
    )

    devise_parameter_sanitizer.permit(
      :account_update,
      keys: customer_fields
    )
  end


helper_method :current_cart, :current_cart_count

  private

  def current_cart
    if customer_signed_in?
      signed_in_customer_cart
    else
      guest_cart
    end
  end

def signed_in_customer_cart
  current_customer.cart || current_customer.create_cart!
end

def guest_cart
  cart = Cart.find_by(id: session[:cart_id])

  return cart if cart.present?

  cart = Cart.create!
  session[:cart_id] = cart.id
  cart
end

  # def current_cart_count
  #   if customer_signed_in?
  #     cart = current_customer.carts.find_by(status: "active")
  #   elsif session[:cart_id]
  #     cart = Cart.find_by(id: session[:cart_id], customer_id: nil, status: "active")
  #   end
  #   cart&.cart_items&.sum(:quantity) || 0
  # end
end
