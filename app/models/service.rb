class Service < ApplicationRecord
  has_many :providers, dependent: :nullify
  has_many :chat_sessions, dependent: :nullify

  validates :key, presence: true, uniqueness: true

  def self.active
    where(is_active: true)
  end

  def name(lang = I18n.locale)
    send("name_#{lang}") || name_th
  end

  def providers_count
    count = providers.count
    count > 0 ? count : 10
  end
end
