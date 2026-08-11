class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :product_name, presence: true
  validates :unit_price,
            numericality: {
              greater_than_or_equal_to: 0
            }
  validates :quantity,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  def subtotal
    quantity * unit_price
  end
  def self.ransackable_attributes(auth_object = nil)
  [ "created_at", "id", "id_value", "line_total", "order_id", "product_id", "product_name", "quantity", "unit_price", "updated_at" ]
  end
  def self.ransackable_associations(_auth_object = nil)
    %w[
      order
      product
    ]
  end
end
