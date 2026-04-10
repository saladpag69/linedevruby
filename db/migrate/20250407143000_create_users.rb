class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :siamcosmo_user_id
      t.string :siamcosmo_token
      t.string :line_id
      t.string :line_display_name
      t.string :shop_id, default: "branch_001"

      t.timestamps
    end

    add_index :users, :username, unique: true
    add_index :users, :siamcosmo_user_id
    add_index :users, :line_id
  end
end
