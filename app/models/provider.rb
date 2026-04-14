class Provider < ApplicationRecord
  belongs_to :service
  belongs_to :user, optional: true

  validates :company_name, presence: true

  scope :active, -> { where(status: "open") }
  scope :verified, -> { where(verified: true) }

  def status_text
    status == "open" ? "เปิดให้บริการ" : "ปิดชั่วคราว"
  end
end
