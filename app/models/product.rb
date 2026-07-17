class Product < ApplicationRecord
  belongs_to :category
  has_many :product_images, dependent: :destroy
  validates :name, presence: true
  validates :product_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :rental_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quanity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :category, presence: true
  validates :sku, uniqueness: true, allow_blank: true
  def self.ransackable_attributes(auth_object = nil)
    [ "avaliable", "category_id", "created_at", "description", "id", "name", "product_price", "rental_price", "sku", "stock_quanity", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
