class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "username",
      "email",
      "first_name",
      "last_name",
      "address_line_one",
      "address_line_two",
      "city",
      "province_id",
      "postal_code",
      "created_at",
      "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
   belongs_to :province, optional: true
   has_many :orders, dependent: :restrict_with_error
end
