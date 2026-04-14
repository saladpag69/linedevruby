class AddIsActiveToServices < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:services, :is_active)
      add_column :services, :is_active, :boolean, default: true, null: false
      add_index :services, :is_active
    end
  end
end
