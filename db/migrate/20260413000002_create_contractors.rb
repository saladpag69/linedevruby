class CreateContractors < ActiveRecord::Migration[8.1]
  def change
    create_table :contractors do |t|
      t.string :name, null: false
      t.string :phone
      t.string :line_id
      t.decimal :rating, precision: 2, scale: 1, default: 0
      t.integer :experience_years, default: 0
      t.json :service_type_slugs, default: []
      t.decimal :rate_per_sqm, precision: 10, scale: 2, default: 0
      t.boolean :available, default: true
      t.boolean :is_mock, default: false
      t.text :description
      t.string :image_url

      t.timestamps
    end
  end
end
