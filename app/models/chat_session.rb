class ChatSession < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :service

  has_many :messages, dependent: :destroy

  scope :active, -> { where(status: "active") }

  def last_message
    messages.order(created_at: :desc).first
  end
end
