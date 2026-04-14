class QuoteMaterial < ApplicationRecord
  belongs_to :quote

  validates :product_slug, presence: true
  validates :product_name, presence: true

  def subtotal
    quantity * unit_price
  end

  def formatted_subtotal
    "฿#{subtotal.to_i}"
  end

  def formatted_unit_price
    "฿#{unit_price.to_i}"
  end
end
