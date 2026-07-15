class CreateProductImages < ActiveRecord::Migration[8.1]
  def change
    create_table :product_images do |t|
      t.integer :product_id
      t.string :alt_text
      t.integer :position

      t.timestamps
    end
  end
end
