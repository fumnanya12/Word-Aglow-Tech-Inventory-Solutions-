class ProductImage < ApplicationRecord
belongs_to :product
 has_one_attached :image
validates :image, presence: true
  def self.ransackable_attributes(auth_object = nil)
    [ "alt_text", "created_at", "id", "position", "product_id", "updated_at" ]
  end
  def self.ransackable_associations(auth_object = nil)
    [ "image_attachment", "image_blob", "product" ]
  end
end
