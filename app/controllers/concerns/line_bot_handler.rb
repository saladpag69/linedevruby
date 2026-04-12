# app/controllers/concerns/line_bot_handler.rb
module LineBotHandler
  extend ActiveSupport::Concern

  SUPPLIER_GROUP_ID = "C825174a05b34cfec346b837944651495"

  def handle_text_event(event)
    user_text = event.message.text.to_s
    user_id   = event.source&.user_id || "unknown"

    Rails.logger.info "🔍 Text user_id: #{user_id}, text: #{user_text}"

    source   = event.source
    group_id = if source.is_a?(Line::Bot::V2::Webhook::GroupSource)
                 source.group_id
    elsif source.is_a?(Line::Bot::V2::Webhook::RoomSource)
                 source.room_id
    end

    messages = if group_id == SUPPLIER_GROUP_ID
                 [ Line::Bot::V2::MessagingApi::TextMessage.new(text: "ไม่สามารถตอบคำถามผู้ค้าได้") ]
    else
                 build_text_reply(user_text, user_id, group_id)
    end

    reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
      reply_token: event.reply_token,
      messages: messages
    )
    client.reply_message(reply_message_request: reply_req)
  end

  def handle_follow_event(event)
    reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
      reply_token: event.reply_token,
      messages: [ Line::Bot::V2::MessagingApi::TextMessage.new(text: "ขอบคุณที่แอดเป็นเพื่อนครับ 🙏") ]
    )
    client.reply_message(reply_message_request: reply_req)
  end

  def handle_postback_event(event)
    user_id = event.source&.user_id || "unknown"
    data    = event.postback.data

    Rails.logger.info "🔍 Postback user_id: #{user_id}, data: #{data}"

    params  = CGI.parse(data)
    action  = params["action"]&.first

    if action == "view_cart" || action == "add_cart"
      messages = if action == "add_cart"
                   if CartService.processing?(user_id)
                     [ LineMessageBuilder.text("กำลังดำเนินการออเดอร์อยู่ครับ ไม่สามารถเพิ่มสินค้าได้ 🔄") ]
                   else
                     sku     = params["sku"]&.first
                     product = sku.present? ? ActiveProduct.all.find { |p| p._id.to_s == sku } : nil
                     if product.nil?
                       [ LineMessageBuilder.text("ไม่พบสินค้า sku: #{sku} ในระบบครับ") ]
                     else
                       Rails.logger.info "🔍 add_cart - user_id: #{user_id}, sku: #{sku}, name: #{product.productname}"
                       item = CartService.add_item(user_id, product)
                       Rails.logger.info "🔍 Cart after add - item: #{item.product_name}(#{item.sku})"
                       [ LineMessageBuilder.text("เพิ่ม #{item.product_name} x#{item.quantity} ลงตะกร้าแล้ว 🛒") ] +
                         LineMessageBuilder.cart_message(user_id)
                     end
                   end
      else
                   LineMessageBuilder.cart_message(user_id)
      end

      reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
        reply_token: event.reply_token,
        messages: messages
      )
      client.reply_message(reply_message_request: reply_req)
      return
    end

    reply_text = case action
    when "process_order"
                   if CartService.processing?(user_id)
                     "กำลังดำเนินการออเดอร์อยู่ครับ กรุณารอสักครู่ 🔄"
                   else
                     summary = CartService.cart_summary(user_id)
                     if summary.nil? || summary[:items].empty?
                       "ตะกร้าของคุณว่างเปล่าครับ 🛒\nพิมพ์ชื่อสินค้าเพื่อค้นหาได้เลยครับ"
                     else
                       CartService.mark_processing!(user_id)
                       order_text = "รายการสั่งซื้อของคุณ:\n#{summary[:items].map { |i| "• #{i.product_name} x#{i.quantity} = ฿#{(i.price.to_f * i.quantity).round}" }.join("\n")}\n\nราคารวม: ฿#{summary[:total].round} บาท\n\nกรุณาโอนเงินและส่งหลักฐานการโอนเงินครับ"
                       CartService.clear_cart(user_id)
                       order_text
                     end
                   end
    when "clear_cart"
                   CartService.clear_cart(user_id)
                   "ล้างตะกร้าเรียบร้อยแล้วครับ 🗑️"
    else
                   "ได้รับ postback: #{data}"
    end

    reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
      reply_token: event.reply_token,
      messages: [ LineMessageBuilder.text(reply_text) ]
    )
    client.reply_message(reply_message_request: reply_req)
  end

  private

  def build_text_reply(user_text, user_id, group_id)
    extracted     = MessageProductExtractor.new(user_text).call
    response_text = extracted[:response]

    products = if response_text.present?
                 ActiveProduct.none
    elsif extracted[:barcode].present?
                 ActiveProduct.all.select { |p| p.barcodeid.to_s == extracted[:barcode] }
    elsif extracted[:keyword].present?
                 ActiveProduct.search(extracted[:keyword], unit: extracted[:unit])
    else
                 ActiveProduct.none
    end

    if response_text.present?
      [ LineMessageBuilder.text(response_text) ]
    elsif extracted[:intent] == :view_cart
      LineMessageBuilder.cart_message(user_id)
    elsif extracted[:intent] == :clear_cart
      CartService.clear_cart(user_id)
      [ LineMessageBuilder.text("ล้างตะกร้าเรียบร้อยแล้วครับ 🗑️") ]
    elsif user_text.strip.empty?
      [ LineMessageBuilder.text("พิมพ์ชื่อสินค้าหรือบาร์โค้ดเพื่อค้นหาได้เลยครับ") ]
    elsif products.empty?
      notify_admin_no_product(user_id: user_id, group_id: group_id, query: user_text)
      [ LineMessageBuilder.text("ไม่พบสินค้า \"#{extracted[:keyword]}\" ในระบบ") ]
    elsif extracted[:intent] == :stock || extracted[:intent] == "ASK_STOCK"
      product      = products.first
      stock        = product.productstock.to_i
      unit_display = extracted[:unit] || product.productunit || "ชิ้น"
      stock_text   = stock.positive? ? "#{stock} #{unit_display}" : "หมด"
      [ LineMessageBuilder.text("#{product.productname} เหลือ #{stock_text}") ]
    else
      bubbles = LineMessageBuilder.product_bubbles(products, base_url: request.base_url)
      [
        Line::Bot::V2::MessagingApi::FlexMessage.new(
          alt_text: "ผลการค้นหา #{user_text}",
          contents: { type: "carousel", contents: bubbles }
        ),
        LineMessageBuilder.text("เลือกสินค้าที่ต้องการได้เลยครับ")
      ]
    end
  end

  def notify_admin_no_product(user_id:, group_id:, query:)
    message = "ผู้ใช้:#{user_id} กลุ่ม:#{group_id} สอบถาม \"#{query}\""
    SupplierLineNotifier.new(message: message).call
  rescue StandardError => e
    Rails.logger.error("notify_admin_no_product failed: #{e.message}")
  end
end
