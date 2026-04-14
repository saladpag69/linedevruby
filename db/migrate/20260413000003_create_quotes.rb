class CreateQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :quotes do |t|
      t.references :service_type, foreign_key: true, null: false
      t.references :contractor, foreign_key: true
      t.references :user, foreign_key: true
      t.string :line_user_id
      t.string :session_key
      t.json :inputs, default: {}
      t.decimal :area, precision: 10, scale: 2, default: 0
      t.decimal :volume, precision: 10, scale: 2, default: 0
      t.decimal :material_total, precision: 10, scale: 2, default: 0
      t.decimal :labor_total, precision: 10, scale: 2, default: 0
      t.decimal :delivery_fee, precision: 10, scale: 2, default: 0
      t.decimal :tax, precision: 10, scale: 2, default: 0
      t.decimal :grand_total, precision: 10, scale: 2, default: 0
      t.string :delivery_option, default: "pickup"
      t.string :status, default: "draft"
      t.string :pdf_url
      t.text :note
      t.json :shop_prices, default: {}

      t.timestamps
    end

    add_index :quotes, :session_key
    add_index :quotes, :status
    add_index :quotes, :line_user_id
  end
end
