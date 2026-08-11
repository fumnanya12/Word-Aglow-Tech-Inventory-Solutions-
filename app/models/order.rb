class Order < ApplicationRecord
  belongs_to :customer

  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :status, presence: true

  def total_price
    order_items.sum(&:subtotal)
  end
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      customer_id
      status
      subtotal
      tax
      total
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      customer
      order_items
      products
    ]
  end
end
