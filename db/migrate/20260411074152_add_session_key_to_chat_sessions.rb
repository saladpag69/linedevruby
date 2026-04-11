class AddSessionKeyToChatSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :chat_sessions, :session_key, :string
    add_index :chat_sessions, :session_key
  end
end
