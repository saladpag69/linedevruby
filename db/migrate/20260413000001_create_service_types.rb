class CreateServiceTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :service_types do |t|
      t.string :slug, null: false, index: { unique: true }
      t.string :icon, default: "🔧"
      t.string :name_th, null: false
      t.string :name_en
      t.string :name_zh
      t.json :inputs, default: []
      t.string :formula, null: false
      t.json :materials, default: []
      t.decimal :labor_rate_per_sqm, precision: 10, scale: 2, default: 0
      t.string :labor_unit, default: "ตร.ม."
      t.boolean :active, default: true
      t.integer :sort_order, default: 0

      t.timestamps
    end
  end
end
