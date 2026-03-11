class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 5, scale: 2

      t.timestamps
    end
  end
end
