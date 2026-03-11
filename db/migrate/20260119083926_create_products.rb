class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :descriotion
      t.decimal :proce, precision: 5, scale: 2

      t.timestamps
    end
  end
end
