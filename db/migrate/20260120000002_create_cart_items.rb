class CreateCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.string :product_name
      t.string :sku
      t.decimal :price, precision: 10, scale: 2
      t.integer :quantity, default: 1
      t.string :unit
      t.timestamps
    end
  end
end
