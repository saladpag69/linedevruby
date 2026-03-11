class CreateModels < ActiveRecord::Migration[8.1]
  def change
    create_table :models do |t|
      t.string :orderable
      t.belongs_to :product, null: false, foreign_key: true
      t.belongs_to :cart, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
