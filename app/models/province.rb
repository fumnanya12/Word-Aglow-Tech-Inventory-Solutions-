class Province < ApplicationRecord
  has_many :customers

  validates :name, presence: true, uniqueness: true
  validates :abbreviation, presence: true, uniqueness: true
  def to_s
    name
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "abbreviation", "created_at", "gst_rate", "hst_rate", "id", "name", "pst_rate", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "customers" ]
  end
end
