class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :chat_session, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :role, null: false
      t.text :content
      t.json :suggestions
      t.boolean :read, default: false

      t.timestamps
    end
    add_index :messages, :role
  end
end
