class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy

  scope :active, -> { where(status: "active").where("expires_at > ?", Time.now) }

  def active?
    status == "active" && expires_at.present? && expires_at > Time.now
  end

  def expired?
    expires_at.present? && expires_at <= Time.now
  end

  def processing?
    status == "processing"
  end
end
