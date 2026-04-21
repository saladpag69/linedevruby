class CalculatorService < ApplicationRecord
  has_many :service_types, dependent: :nullify

  validates :slug, presence: true, uniqueness: true
  validates :name_th, presence: true

  scope :active, -> { where(active: true).order(:sort_order) }
  scope :sorted, -> { order(:sort_order) }

  def name(lang = I18n.locale)
    send("name_#{lang}") || name_th
  end

  def input_fields
    read_attribute(:input_fields) || []
  end

  def presets
    read_attribute(:presets) || []
  end

  def materials
    read_attribute(:materials) || []
  end
end
