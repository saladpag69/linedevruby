class RenameServicesCreateCalculatorServices < ActiveRecord::Migration[8.1]
  def change
    rename_table :services, :communicate_services

    create_table :calculator_services do |t|
      t.string :slug, null: false, index: { unique: true }
      t.string :name_th, null: false
      t.string :name_en
      t.string :icon, default: "🔧"
      t.json :input_fields, default: []
      t.json :presets, default: []
      t.json :materials, default: []
      t.integer :sort_order, default: 0
      t.boolean :active, default: true
      t.timestamps
    end

    add_reference :service_types, :calculator_service, foreign_key: true, index: true
    add_column :service_types, :presets, :json, default: []
  end
end
