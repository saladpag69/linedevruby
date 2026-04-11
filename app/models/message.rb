class Message < ApplicationRecord
  belongs_to :chat_session
  belongs_to :user, optional: true

  validates :role, presence: true

  def user?
    role == "user"
  end

  def bot?
    role == "bot"
  end
end
