class UpdateServicesForSiamcosmo < ActiveRecord::Migration[8.1]
  def change
    change_table :services do |t|
      t.string :key
      t.string :name_th
      t.string :name_en
      t.string :name_zh
      t.string :icon
      t.text :greeting_message
      t.json :suggestions
      t.boolean :is_active, default: true
    end
    add_index :services, :key, unique: true
    add_index :services, :is_active
  end
end
