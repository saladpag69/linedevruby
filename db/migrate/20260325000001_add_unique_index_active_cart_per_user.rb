class AddUniqueIndexActiveCartPerUser < ActiveRecord::Migration[8.1]
  def up
    # Remove stale duplicate active carts first, keep only newest per user
    Cart.where(status: "active")
        .select(:line_user_id)
        .group(:line_user_id)
        .having("COUNT(*) > 1")
        .pluck(:line_user_id)
        .each do |uid|
          Cart.where(line_user_id: uid, status: "active")
              .order(created_at: :desc)
              .offset(1)
              .each { |c| c.cart_items.destroy_all; c.destroy }
        end

    add_index :carts, :line_user_id, unique: true,
              where: "status = 'active'",
              name: "index_carts_active_unique_user"
  end

  def down
    remove_index :carts, name: "index_carts_active_unique_user"
  end
end
