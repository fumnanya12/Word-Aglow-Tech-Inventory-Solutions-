class AddCustomerDetailsToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :username, :string
    add_column :customers, :first_name, :string
    add_column :customers, :last_name, :string
    add_column :customers, :address_line_one, :string
    add_column :customers, :address_line_two, :string
    add_column :customers, :city, :string
    add_column :customers, :province, :string
    add_column :customers, :postal_code, :string
    add_column :customers, :country, :string, default: "Canada"

    add_index :customers, :username, unique: true
  end
end
