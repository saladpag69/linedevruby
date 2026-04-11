class User < ApplicationRecord
  # Devise disabled for now
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable,
  #        :confirmable, :trackable

  validates :username, presence: true, uniqueness: true, if: :username_required?

  has_many :providers, dependent: :destroy
  has_many :chat_sessions, dependent: :destroy
  has_many :messages, through: :chat_sessions

  enum role: { user: 0, provider: 1, admin: 2 }

  def username_required?
    username.present?
  end

  def name
    username || email.split("@").first
  end

  def provider?
    role == "provider"
  end

  def admin?
    role == "admin"
  end

  # Helper methods for Devise compatibility
  def email_required?
    false
  end

  def email
    read_attribute(:email)
  end

  def password
    nil
  end

  def password=
    nil
  end
end
