class Page < ApplicationRecord
    validates 
    def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "id", "published", "slug", "title", "updated_at"]
  end
   def self.ransackable_associations(auth_object = nil)
    []
  end
end
