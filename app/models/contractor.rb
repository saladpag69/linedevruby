class Contractor < ApplicationRecord
  has_many :quotes, dependent: :restrict_with_error

  validates :name, presence: true

  scope :available, -> { วววสมwhere(available: true) }
  scope :mock, -> { where(is_mock: true) }
  scope :real, -> { where(is_mock: false) }
  scope :for_service, ->(slug) { where("service_type_slugs LIKE ?", "%#{slug}%") }

  def rating_stars
    "★" * rating.to_i + "☆" * (5 - rating.to_i)
  end

  def experience_label
    "#{experience_years} ปี"
  end
end
