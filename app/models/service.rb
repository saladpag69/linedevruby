class Service < ApplicationRecord
  has_many :providers, dependent: :nullify
  has_many :chat_sessions, dependent: :nullify

  validates :key, presence: true, uniqueness: true

  scope :active, -> { where(is_active: true) }

  def name(lang = I18n.locale)
    send("name_#{lang}") || name_th
  end

  def providers_count
    providers.count
  end
end
