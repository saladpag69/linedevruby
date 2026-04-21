class ServiceType < ApplicationRecord
  belongs_to :calculator_service, optional: true

  has_many :quotes, dependent: :restrict_with_error

  validates :slug, presence: true, uniqueness: true
  validates :name_th, presence: true
  validates :formula, presence: true

  scope :active, -> { where(active: true).order(:sort_order) }
  scope :sorted, -> { order(:sort_order) }

  def name(lang = I18n.locale)
    send("name_#{lang}") || name_th
  end

  def input_fields
    inputs || []
  end

  def material_definitions
    materials || []
  end

  def presets
    read_attribute(:presets) || []
  end

  def calculate_values(user_inputs)
    width = user_inputs[:width].to_f
    length = user_inputs[:length].to_f
    height = user_inputs[:height].to_f
    thickness = user_inputs[:thickness].to_f
    depth = user_inputs[:depth].to_f

    area = width * length
    volume = area * [ thickness, depth, height ].compact.max

    { area: area, volume: volume }
  end

  def evaluate_formula(user_inputs, formula_str)
    vals = calculate_values(user_inputs)
    return 0 if formula_str.blank?

    formula_str.gsub(/\b(area|volume|width|length|height|thickness|depth)\b/) do |match|
      vals[match.to_sym] || 0
    end
  end
end
