class AddStatusToCarts < ActiveRecord::Migration[8.1]
  def change
    add_column :carts, :status, :string, default: "active", null: false
  end
end
