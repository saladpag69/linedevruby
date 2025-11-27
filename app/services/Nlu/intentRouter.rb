module Nlu
class IntentRouter
  def self.call(nlu:, customer:)
    new(nlu, customer).call
  end

  def initialize(nlu, customer)
    @intent   = nlu[:intent]
    @entities = nlu[:entities] || {}
    @customer = customer
  end

  def call
    case @intent
    when "ASK_PRICE"
      AskPriceHandler.call(@entities)
    when "ASK_ORDER_STATUS"
      AskOrderStatusHandler.call(@entities, @customer)
    when "ASK_PRODUCT_SPEC"
      AskProductSpecHandler.call(@entities)
    when "ASK_SHIPPING_COST"
      AskShippingCostHandler.call(@entities)
    else
      "ไม่แน่ใจว่าลูกค้าสอบถามเรื่องอะไรครับ รบกวนพิมพ์ใหม่อีกครั้งได้ไหมครับ"
    end
  end
  
  class AskPriceHandler
    def self.call(entities)
      product_name = entities[:product] || "วงส้วม"
      size         = entities[:size]
  
      scope = Product.where("name LIKE ?", "%#{product_name}%")
      scope = scope.where(size: size) if size
  
      product = scope.first
  
      return "ยังไม่มีข้อมูลสินค้านี้ครับ" unless product
  
      "วงส้วม #{product.size} ราคา #{product.price} บาทครับ"
    end
  end
  
  class AskOrderStatusHandler
    def self.call(entities, customer)
      return "ไม่พบข้อมูลลูกค้า" unless customer
  
      product_name = entities[:product] || "วงส้วม"
  
      order = customer.orders
                      .joins(:order_items)
                      .where("order_items.product_name LIKE ?", "%#{product_name}%")
                      .order(created_at: :desc)
                      .first
  
      return "ยังไม่พบประวัติการสั่งวงส้วมครับ" unless order
  
      "ออเดอร์วงส้วมของคุณจะจัดส่งวันที่ #{I18n.l(order.delivery_date)} ครับ"
    end
  end

  class AskProductSpecHandler
    def self.call(entities)
      product = Product.find_by(name: entities[:product], size: entities[:size])
  
      return "ยังไม่มีข้อมูลสเปควงส้วมขนาดนี้ครับ" unless product
  
      "วงส้วม #{product.size} สูง #{product.height} ซม. หนา #{product.thickness} ซม. ครับ"
    end
  end
  class AskShippingCostHandler
    def self.call(entities)
      quantity = entities[:quantity]&.to_i
      size     = entities[:size]
  
      return "ขอทราบจำนวนวงก่อนครับ เช่น วงส้วม 80 จำนวน 40 วง" unless quantity&.positive?
  
      product = Product.find_by(name: entities[:product], size: size)
      return "ไม่พบราคาวงส้วมขนาดนี้ครับ" unless product
  
      price_per_unit = product.price
      total = price_per_unit * quantity
  
      config = ShopConfig.first # free_shipping_min, shipping_fee
  
      if total >= config.free_shipping_min
        "ยอดรวม #{total} บาท ส่งฟรีครับ"
      else
        shipping = config.shipping_fee
        "ยอดสินค้า #{total} บาท ค่าส่ง #{shipping} บาท รวมทั้งสิ้น #{total + shipping} บาทครับ"
      end
    end
  end

end
end
