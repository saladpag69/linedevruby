class AddLineUserIdAndExpiresAtToCarts < ActiveRecord::Migration[8.1]
  def change
    add_column :carts, :line_user_id, :string
    add_column :carts, :expires_at, :datetime
    add_index :carts, :line_user_id
  end
end
