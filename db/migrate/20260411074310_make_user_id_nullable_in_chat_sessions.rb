class MakeUserIdNullableInChatSessions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :chat_sessions, :user_id, true
  end
end
