class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    change_table :users do |t|
      t.string :email, index: true
      t.string :encrypted_password
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
      t.string :role, default: "user"
    end
    add_index :users, :reset_password_token, unique: true
  end
end
