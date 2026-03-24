# 🔧 แก้ Intent Parser — ค้นหาสินค้าไม่เจอ

## ปัญหาที่พบจาก log จริง

| ลูกค้าพิมพ์ | ปัญหา |
|------------|-------|
| "ปูนเสือ40" | ติดกัน ค้นหาไม่เจอ |
| "หิน 3/4" | slash ถูกตัดออก → "หิน 3 4" |
| "สต๊อก ปูน" | ไม้ตรีต่างกัน → ไม่ match |
| "ปูนเสือ40 ลวด10 มัด" | หลายสินค้าในข้อความเดียว |

---

## แก้ไข app/services/bot_handler.rb

```ruby
class BotHandler
  PRICE_KEYWORDS  = %w[ราคา เท่าไหร่ เท่าไร ราคาเท่า].freeze
  STOCK_KEYWORDS  = ['สต็อก', 'สต๊อก', 'สตอก', 'คงเหลือ', 'มีไหม', 'มีของไหม', 'เหลือไหม'].freeze
  ORDER_KEYWORDS  = %w[สั่ง ซื้อ ขอ จอง สั่งซื้อ].freeze

  def initialize(message)
    @message = message.to_s.strip
  end

  def reply
    case intent
    when :price  then handle_price
    when :stock  then handle_stock
    when :order  then handle_order
    else              handle_search
    end
  end

  private

  def intent
    return :price  if contains?(PRICE_KEYWORDS)
    return :stock  if contains?(STOCK_KEYWORDS)
    return :order  if contains?(ORDER_KEYWORDS)
    :search
  end

  def contains?(keywords)
    keywords.any? { |kw| normalize(@message).include?(normalize(kw)) }
  end

  # ─── Normalize ──────────────────────────────────
  # ลบ intent keywords ออก เหลือชื่อสินค้า
  # รักษา "/" และตัวเลขไว้ (หิน 3/4, เหล็ก 12mm)

  def normalize(text)
    text.to_s
        .gsub('สต๊อก', 'สต็อก')   # normalize ไม้ตรี
        .gsub(/\s+/, ' ')
        .strip
        .downcase
  end

  def extract_keyword
    stop_words = PRICE_KEYWORDS + STOCK_KEYWORDS + ORDER_KEYWORDS +
                 %w[ได้ไหม ครับ นะ หน่อย ขอดู อยากรู้]
    result = @message.dup
    stop_words.each { |w| result.gsub!(w, ' ') }
    result.gsub(/\s+/, ' ').strip
  end

  # ─── Search (fuzzy) ────────────────────────────

  def find_product(keyword = nil)
    kw = normalize(keyword || extract_keyword)
    return nil if kw.blank?

    # 1. ตรงเป๊ะก่อน
    product = Product.where(name: /\A#{Regexp.escape(kw)}\z/i).first
    return product if product

    # 2. contains
    product = Product.where(name: /#{Regexp.escape(kw)}/i).first
    return product if product

    # 3. ถ้าไม่เจอ ลองตัดตัวเลขออกแล้วหาชื่อแบรนด์
    brand = kw.gsub(/[\d\/]+/, '').strip
    return nil if brand.length < 2
    Product.where(name: /#{Regexp.escape(brand)}/i).first
  end

  # แยกหลายสินค้าจากข้อความเดียว
  # เช่น "ปูนเสือ40 ลวด10 มัด" → ["ปูนเสือ 40", "ลวด 10"]
  def extract_multiple_keywords
    # แยกด้วย space แล้ว group ชื่อ+ตัวเลข
    tokens = extract_keyword.split(/\s+/)
    groups = []
    current = []
    tokens.each do |t|
      if t.match?(/^\d/) && current.any?
        current << t
        groups << current.join(' ')
        current = []
      else
        groups << current.join(' ') if current.any?
        current = [t]
      end
    end
    groups << current.join(' ') if current.any?
    groups.reject(&:blank?)
  end

  # ─── Handlers ───────────────────────────────────

  def handle_search
    keywords = extract_multiple_keywords

    # ถ้ามีหลายสินค้า
    if keywords.length > 1
      results = keywords.map { |kw| find_product(kw) }.compact
      if results.any?
        return results.map { |p|
          "📦 #{p.name}\n💰 #{format_price(p.price)} บาท/#{p.unit} | เหลือ #{p.stock} #{p.unit}"
        }.join("\n\n")
      end
    end

    product = find_product
    if product
      "📦 #{product.name}\n" \
      "💰 #{format_price(product.price)} บาท/#{product.unit}\n" \
      "📊 เหลือ #{product.stock} #{product.unit}\n\n" \
      "สั่งได้เลยครับ เช่น 'สั่ง#{product.name} 5 #{product.unit}'"
    else
      not_found_reply
    end
  end

  def handle_price
    product = find_product
    return not_found_reply unless product

    "💰 #{product.name}\n" \
    "ราคา #{format_price(product.price)} บาท/#{product.unit}\n" \
    "เหลือ #{product.stock} #{product.unit}"
  end

  def handle_stock
    product = find_product
    return not_found_reply unless product

    status = product.stock > 0 ? "✅ มีสินค้า" : "❌ สินค้าหมด"
    "#{status}\n📦 #{product.name}\nคงเหลือ #{product.stock} #{product.unit}"
  end

  def handle_order
    product = find_product
    qty     = extract_qty
    return "ระบุสินค้าที่ต้องการสั่งด้วยนะครับ\nเช่น 'สั่งปูนเสือ 10 ถุง'" unless product

    total = product.price * qty
    "🛒 สรุปออเดอร์\n" \
    "#{product.name} x#{qty} #{product.unit}\n" \
    "💰 รวม #{format_price(total)} บาท\n\n" \
    "ยืนยัน พิมพ์ 'ยืนยัน' ได้เลยครับ"
  end

  def not_found_reply
    kw = extract_keyword
    "ขออภัยครับ ไม่พบ \"#{kw}\"\n\n" \
    "ลองพิมพ์แค่ชื่อแบรนด์ได้เลยครับ เช่น:\n" \
    "• ปูนเสือ\n• ปูนนก\n• หิน\n• ทราย\n• เหล็ก"
  end

  def extract_qty
    match = @message.match(/(\d+)/)
    match ? match[1].to_i : 1
  end

  def format_price(price)
    "%.2f" % price
  end
end
```

---

## ✅ ทดสอบหลังแก้

| ลูกค้าพิมพ์ | ผลที่ควรได้ |
|------------|------------|
| `ปูนเสือ40` | เจอ ปูนเสือ |
| `หิน 3/4` | เจอ หิน 3/4 |
| `สต๊อก ปูน` | แสดงสต็อกปูน |
| `ปูนเสือ40 ลวด10 มัด` | แสดง 2 สินค้า |
| `ราคา ปูนนก` | แสดงราคาปูนนก |
| `นกเพชร` | not found + แนะนำให้พิมพ์แค่ ปูนนก |

---

## Checklist

```
□ bundle install (ไม่มี gem เพิ่ม ข้ามได้)
□ copy code นี้ทับ app/services/bot_handler.rb
□ rails server restart
□ ทดสอบใน LINE ครบ 6 case ด้านบน
□ ทุก case ผ่าน → commit แล้วเดินหน้า QR Payment
```
