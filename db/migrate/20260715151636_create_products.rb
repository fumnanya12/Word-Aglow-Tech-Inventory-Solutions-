class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.integer :category_id
      t.string :name
      t.text :description
      t.float :rental_price
      t.float :product_price
      t.integer :stock_quanity
      t.boolean :avaliable
      t.string :sku

      t.timestamps
    end
  end
end
