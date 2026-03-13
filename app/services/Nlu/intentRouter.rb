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
    when "ASK_STOCK"
      AskStockHandler.call(@entities)
    when "ORDER"
      OrderHandler.call(@entities)
    when "QUOTATION"
      QuotationHandler.call(@entities)
    else
      "ไม่แน่ใจว่าลูกค้าสอบถามเรื่องอะไรครับ รบกวนพิมพ์ใหม่อีกครั้งได้ไหมครับ"
    end
  end

  class AskPriceHandler
    def self.call(entities)
      product_name = entities[:product]&.to_s || ""

      products = ActiveProduct.search(product_name)
      return "ไม่พบสินค้า \"#{product_name}\" ในระบบครับ" if products.empty?

      product = products.first
      "สินค้า #{product.productname} ราคา #{product.productsale1} บาทครับ"
    end
  end

  class AskStockHandler
    def self.call(entities)
      product_name = entities[:product]&.to_s || ""

      products = ActiveProduct.search(product_name)
      return "ไม่พบสินค้า \"#{product_name}\" ในระบบครับ" if products.empty?

      product = products.first
      stock = product.productstock.to_i
      if stock.positive?
        "สินค้า #{product.productname} มีสต็อก #{stock} ชิ้นครับ"
      else
        "สินค้า #{product.productname} ขณะนี้สต็อกหมดครับ"
      end
    end
  end

  class OrderHandler
    def self.call(entities)
      product_name = entities[:product]&.to_s || ""

      products = ActiveProduct.search(product_name)
      return "ไม่พบสินค้า \"#{product_name}\" ในระบบครับ" if products.empty?

      product = products.first
      "ต้องการสั่งสินค้า #{product.productname} ราคา #{product.productsale1} บาท กรุณายืนยันครับ"
    end
  end

  class QuotationHandler
    def self.call(entities)
      product_name = entities[:product]&.to_s || ""

      products = ActiveProduct.search(product_name)
      return "ไม่พบสินค้า \"#{product_name}\" ในระบบครับ" if products.empty?

      product = products.first
      "ใบเสนอราคา #{product.productname}\nราคาปกติ: #{product.productsale2} บาท\nราคาพิเศษ: #{product.productsale1} บาท\nสต็อก: #{product.productstock} ชิ้น"
    end
  end
end
end
