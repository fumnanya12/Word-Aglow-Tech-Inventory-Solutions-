class ReplaceProvinceWithProvinceReferenceOnCustomers < ActiveRecord::Migration[8.1]
  def change
    remove_column :customers, :province, :string

    add_reference :customers,
                  :province,
                  null: true,
                  foreign_key: true
  end
end
