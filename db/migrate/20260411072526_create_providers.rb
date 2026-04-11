class CreateProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :providers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.string :company_name
      t.text :description
      t.json :work_types
      t.string :phone
      t.string :line_id
      t.string :address
      t.decimal :rating, precision: 2, scale: 1, default: 0
      t.integer :jobs_completed, default: 0
      t.string :status, default: "open"
      t.boolean :verified, default: false

      t.timestamps
    end
    add_index :providers, :status
    add_index :providers, :verified
  end
end
