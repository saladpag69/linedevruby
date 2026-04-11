class CreateChatSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.string :status, default: "active"

      t.timestamps
    end
    add_index :chat_sessions, :status
  end
end
