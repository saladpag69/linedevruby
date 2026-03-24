# app/services/line_message_builder.rb
# Builds LINE message objects — no controller/request dependency except base_url
class LineMessageBuilder
  FALLBACK_PRODUCT_IMAGE = "https://images.unsplash.com/photo-1448630360428-65456885c650"

  def self.default_quick_reply
    {
      items: [
        { type: "action", action: { type: "postback", label: "สั่งซื้อ",    data: "action=process_order" } },
        { type: "action", action: { type: "postback", label: "ดูตะกร้า",   data: "action=view_cart"     } },
        { type: "action", action: { type: "postback", label: "ล้างตะกร้า", data: "action=clear_cart"    } }
      ]
    }
  end

  def self.text(message)
    Line::Bot::V2::MessagingApi::TextMessage.new(
      text: message,
      quickReply: default_quick_reply
    )
  end

  def self.product_bubbles(products, base_url:)
    products.first(5).map do |product|
      price_primary   = product.productsale1.to_s
      price_secondary = product.productsale2.to_s
      image_url       = product.productimage.presence || FALLBACK_PRODUCT_IMAGE

      {
        type: "bubble",
        hero: {
          type: "image",
          url: image_url,
          size: "full",
          aspectRatio: "20:13",
          aspectMode: "cover",
          action: { type: "uri", uri: base_url }
        },
        body: {
          type: "box",
          layout: "vertical",
          contents: [
            { type: "text", text: product.productname.to_s, weight: "bold", size: "lg", wrap: true },
            { type: "text", text: "บาร์โค้ด: #{product.barcodeid}", size: "sm", color: "#666666", wrap: true },
             
            {
              type: "box", layout: "vertical", margin: "lg", spacing: "sm",
              contents: [
                { type: "box", layout: "baseline", spacing: "sm", contents: [
                  { type: "text", text: "ราคาเต็ม",   color: "#aaaaaa", size: "sm", flex: 2 },
                  { type: "text", text: "฿#{price_secondary}", size: "sm", color: "#111111", flex: 4 }
                ]},
                { type: "box", layout: "baseline", spacing: "sm", contents: [
                  { type: "text", text: "ราคาพิเศษ", color: "#aaaaaa", size: "sm", flex: 2 },
                  { type: "text", text: "฿#{price_primary}",   size: "sm", color: "#0ea5e9", flex: 4 }
                ]},
                { type: "box", layout: "baseline", spacing: "sm", contents: [
                  { type: "text", text: "สต็อก",      color: "#aaaaaa", size: "sm", flex: 2 },
                  { type: "text", text: "#{product.productstock} ชิ้น", size: "sm", color: "#111111", flex: 4 }
                ]}
              ]
            }
          ]
        },
        footer: {
          type: "box", layout: "vertical", spacing: "sm", flex: 0,
          contents: [
            # {
            #   type: "button", style: "link", height: "sm",
            #   action: { type: "uri", label: "เปิดดูสินค้า", uri: "#{base_url}/aboutus?q=#{CGI.escape(product.productname.to_s)}" }
            # },
            {
              type: "button", style: "primary", height: "sm",
              action: {
                type: "postback", label: "เลือกสินค้า",
                data: "action=add_cart&sku=#{product._id}"
              }
            }
          ]
        }
      }
    end
  end

  def self.cart_message(user_id)
    summary = CartService.cart_summary(user_id)

    if summary.nil? || summary[:items].empty?
      return [ Line::Bot::V2::MessagingApi::TextMessage.new(
        text: "ตะกร้าของคุณว่างเปล่าครับ 🛒\nพิมพ์ชื่อสินค้าเพื่อค้นหาได้เลยครับ",
        quickReply: default_quick_reply
      ) ]
    end

    bubbles = summary[:items].first(5).map do |item|
      {
        type: "bubble",
        body: {
          type: "box", layout: "vertical",
          contents: [
            { type: "text", text: item.product_name, weight: "bold", size: "lg", wrap: true },
            { type: "text", text: "#{item.quantity} #{item.unit} x ฿#{item.price} = ฿#{(item.price.to_f * item.quantity).round}", size: "md", color: "#666666" }
          ]
        }
      }
    end

    total_text = "ราคารวม: ฿#{summary[:total].round} บาท (#{summary[:item_count]} รายการ)"
    summary_text = summary[:items].map { |i| "• #{i.product_name} x#{i.quantity} = ฿#{(i.price.to_f * i.quantity).round}" }.join("\n")

    [
      Line::Bot::V2::MessagingApi::TextMessage.new(text: "🛒 ตะกร้าของคุณ\n\n#{summary_text}\n\n#{total_text}"),
      Line::Bot::V2::MessagingApi::FlexMessage.new(
        alt_text: "ตะกร้าสินค้า",
        contents: { type: "carousel", contents: bubbles }
      ),
      Line::Bot::V2::MessagingApi::TextMessage.new(
        text: "กรุณาเลือกดำเนินการ",
        quickReply: default_quick_reply
      )
    ]
  end
end
