class CreateQuoteMaterials < ActiveRecord::Migration[8.1]
  def change
    create_table :quote_materials do |t|
      t.references :quote, foreign_key: true, null: false
      t.string :product_slug, null: false
      t.string :product_name, null: false
      t.integer :quantity, default: 0
      t.string :unit, default: "ชิ้น"
      t.decimal :unit_price, precision: 10, scale: 2, default: 0
      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.string :shop_id, default: "branch_001"

      t.timestamps
    end

    add_index :quote_materials, [ :quote_id, :product_slug ]
  end
end
