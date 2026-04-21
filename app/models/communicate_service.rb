class CommunicateService < ApplicationRecord
  self.table_name = "communicate_services"

  has_many :providers, class_name: "Provider", foreign_key: "service_id", dependent: :nullify
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
