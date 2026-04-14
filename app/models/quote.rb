class Quote < ApplicationRecord
  belongs_to :service_type
  belongs_to :contractor, optional: true
  belongs_to :user, optional: true
  has_many :quote_materials, dependent: :destroy

  validates :service_type, presence: true

  scope :draft, -> { where(status: "draft") }
  scope :sent, -> { where(status: "sent") }
  scope :ordered, -> { where(status: "ordered") }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_line_user, ->(line_id) { where(line_user_id: line_id) }

  TAX_RATE = 0.07
  DEFAULT_DELIVERY_FEE = 350

  before_save :calculate_totals

  def material_total=(value)
    write_attribute(:material_total, value.to_s.gsub(/[^\d.]/, "").to_f)
  end

  def labor_total=(value)
    write_attribute(:labor_total, value.to_s.gsub(/[^\d.]/, "").to_f)
  end

  def delivery_fee=(value)
    write_attribute(:delivery_fee, value.to_s.gsub(/[^\d.]/, "").to_f)
  end

  def tax
    (material_total + labor_total) * TAX_RATE
  end

  def grand_total
    material_total + labor_total + delivery_fee + self.tax
  end

  def delivery_option_label
    case delivery_option
    when "delivery" then "จัดส่ง"
    when "pickup" then "รับที่ร้าน"
    else delivery_option
    end
  end

  def status_label
    case status
    when "draft" then "ร่าง"
    when "sent" then "ส่งแล้ว"
    when "ordered" then "สั่งซื้อแล้ว"
    else status
    end
  end

  def formatted_date
    created_at.strftime("%d/%m/%Y")
  end

  def inputs_display
    inputs.map { |k, v| "#{k}: #{v}" }.join(", ")
  end

  private

  def calculate_totals
    self.tax = (material_total + labor_total) * TAX_RATE
    self.grand_total = material_total + labor_total + delivery_fee + tax
  end
end
