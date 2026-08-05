class Cart < ApplicationRecord
  belongs_to :customer
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

    def total_price
      cart_items.includes(:product).sum do |item|
        item.quantity * item.product.product_price
      end
    end

  def total_quantity
    cart_items.sum(:quantity)
  end
end
