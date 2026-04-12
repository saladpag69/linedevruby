class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  validates :username, uniqueness: true, allow_blank: true

  has_many :providers, dependent: :destroy
  has_many :chat_sessions, dependent: :destroy
  has_many :messages, through: :chat_sessions

  def role
    read_attribute(:role) || "user"
  end

  def role=(value)
    write_attribute(:role, value)
  end

  def provider?
    role == "provider"
  end

  def admin?
    role == "admin"
  end

  def name
    username || email.split("@").first
  end
end
