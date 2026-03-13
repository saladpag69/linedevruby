# 🤖 Week 2 — Core Bot: LINE Webhook + Intent Parser

## เป้าหมาย
ลูกค้าพิมพ์ใน LINE → บอทตอบราคา / สต็อก / รับออเดอร์ได้จริง

---

## Stack
- Ruby on Rails 7
- line-bot-sdk-ruby
- MongoDB (Mongoid)

---

## Step 1 — ติดตั้ง Gem

เพิ่มใน `Gemfile`:

```ruby
gem 'line-bot-api'
gem 'mongoid'
```

```bash
bundle install
```

---

## Step 2 — Routes

`config/routes.rb`:

```ruby
Rails.application.routes.draw do
  post '/webhook/line', to: 'line_webhook#receive'
end
```

---

## Step 3 — LINE Webhook Controller

สร้างไฟล์ `app/controllers/line_webhook_controller.rb`:

```ruby
class LineWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    body    = request.body.read
    sig     = request.env['HTTP_X_LINE_SIGNATURE']
    client  = build_client

    unless client.validate_signature(body, sig)
      return render json: { error: 'Invalid signature' }, status: 401
    end

    events = client.parse_events_from(body)

    events.each do |event|
      next unless event.is_a?(Line::Bot::Event::Message)
      next unless event.type == Line::Bot::Event::MessageType::Text

      reply_token = event['replyToken']
      user_message = event.message['text']

      reply_text = BotHandler.new(user_message).reply
      client.reply_message(reply_token, { type: 'text', text: reply_text })
    end

    render json: { status: 'ok' }
  end

  private

  def build_client
    Line::Bot::Client.new do |config|
      config.channel_secret       = Rails.application.credentials.line[:channel_secret]
      config.channel_token        = Rails.application.credentials.line[:channel_access_token]
    end
  end
end
```

---

## Step 4 — Intent Parser + Bot Handler

สร้างไฟล์ `app/services/bot_handler.rb`:

```ruby
class BotHandler
  PRICE_KEYWORDS  = %w[ราคา เท่าไหร่ เท่าไร ราคาเท่า].freeze
  STOCK_KEYWORDS  = %w[มีไหม สต็อก คงเหลือ มีของไหม เหลือไหม].freeze
  ORDER_KEYWORDS  = %w[สั่ง ซื้อ ขอ จอง].freeze

  def initialize(message)
    @message = message.to_s.strip
  end

  def reply
    case intent
    when :price  then handle_price
    when :stock  then handle_stock
    when :order  then handle_order
    else              default_reply
    end
  end

  private

  # ─── Intent Detection ───────────────────────────

  def intent
    return :price  if contains?(PRICE_KEYWORDS)
    return :stock  if contains?(STOCK_KEYWORDS)
    return :order  if contains?(ORDER_KEYWORDS)
    :unknown
  end

  def contains?(keywords)
    keywords.any? { |kw| @message.include?(kw) }
  end

  # ─── Handlers ───────────────────────────────────

  def handle_price
    product = find_product
    return "ขออภัยครับ ไม่พบสินค้าที่ต้องการ 🙏\nลองพิมพ์ชื่อสินค้าใหม่ได้เลยครับ" unless product

    "📦 #{product.name}\n" \
    "💰 ราคา: #{format_price(product.price)} บาท/#{product.unit}\n" \
    "📊 สต็อก: #{product.stock} #{product.unit}\n\n" \
    "สนใจสั่งพิมพ์ได้เลยครับ เช่น 'สั่ง#{product.name} 5 #{product.unit}'"
  end

  def handle_stock
    product = find_product
    return "ขออภัยครับ ไม่พบสินค้าที่ต้องการ 🙏" unless product

    status = product.stock > 0 ? "✅ มีสินค้า" : "❌ สินค้าหมด"
    "#{status}\n" \
    "📦 #{product.name}\n" \
    "คงเหลือ: #{product.stock} #{product.unit}"
  end

  def handle_order
    product = find_product
    qty     = extract_qty
    return "ระบุสินค้าที่ต้องการสั่งด้วยนะครับ\nเช่น 'สั่งปูน TPI 10 ถุง'" unless product

    total = product.price * qty
    "🛒 สรุปออเดอร์\n" \
    "#{product.name} x#{qty} #{product.unit}\n" \
    "💰 รวม: #{format_price(total)} บาท\n\n" \
    "ยืนยันออเดอร์ พิมพ์ 'ยืนยัน' ได้เลยครับ"
  end

  def default_reply
    "สวัสดีครับ บ้านสยามวัสดุ 🏗️\n\n" \
    "พิมพ์ได้เลยครับ เช่น:\n" \
    "• 'ราคาปูน TPI'\n" \
    "• 'มีเหล็ก 12 มิลไหม'\n" \
    "• 'สั่งปูน 10 ถุง'"
  end

  # ─── Helpers ────────────────────────────────────

  def find_product
    keyword = extract_keyword
    return nil if keyword.blank?
    Product.where(name: /#{Regexp.escape(keyword)}/i).first
  end

  def extract_keyword
    stop_words = PRICE_KEYWORDS + STOCK_KEYWORDS + ORDER_KEYWORDS +
                 %w[ได้ไหม ได้เลย ครับ นะ หน่อย]
    result = @message.dup
    stop_words.each { |w| result.gsub!(w, '') }
    result.gsub(/\d+/, '').strip
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

## Step 5 — Product Model (MongoDB)

สร้างไฟล์ `app/models/product.rb`:

```ruby
class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,   type: String
  field :sku,    type: String
  field :price,  type: Float,   default: 0.0
  field :unit,   type: String,  default: 'ชิ้น'
  field :stock,  type: Integer, default: 0

  index({ name: 1 })
end
```

---

## Step 6 — เพิ่มสินค้าตัวอย่างใน DB

```bash
rails console
```

```ruby
Product.create!([
  { name: 'ปูน TPI',        sku: 'CEM001', price: 145.0,  unit: 'ถุง',  stock: 200 },
  { name: 'ปูน SCG',        sku: 'CEM002', price: 150.0,  unit: 'ถุง',  stock: 150 },
  { name: 'เหล็ก 12 มิล',   sku: 'STL012', price: 320.0,  unit: 'เส้น', stock: 80  },
  { name: 'เหล็ก 16 มิล',   sku: 'STL016', price: 480.0,  unit: 'เส้น', stock: 50  },
  { name: 'ทราย',            sku: 'SND001', price: 450.0,  unit: 'คิว',  stock: 30  },
  { name: 'หิน',             sku: 'RCK001', price: 550.0,  unit: 'คิว',  stock: 25  },
  { name: 'สีขาว TOA',      sku: 'PNT001', price: 650.0,  unit: 'ถัง',  stock: 40  },
  { name: 'อิฐแดง',          sku: 'BRK001', price: 4.5,    unit: 'ก้อน', stock: 5000},
])

puts "สินค้าทั้งหมด: #{Product.count} รายการ"
```

---

## Step 7 — ทดสอบ Local ด้วย ngrok

```bash
# Terminal 1 — start Rails
rails server -p 3001

# Terminal 2 — เปิด tunnel
ngrok http 3001
# จะได้ URL เช่น https://abc123.ngrok.io
```

นำ URL ไปตั้งใน LINE Developer Console:
```
Webhook URL: https://abc123.ngrok.io/webhook/line
```

เปิด **"Use webhook"** → กด **Verify** → ต้องได้ ✅ Success

---

## Step 8 — ทดสอบใน LINE Chat

พิมพ์ข้อความเหล่านี้แล้วบอทต้องตอบถูก:

| ข้อความที่พิมพ์ | ผลที่คาดหวัง |
|----------------|-------------|
| `ราคาปูน TPI` | แสดงราคา 145 บาท/ถุง |
| `มีเหล็ก 12 มิลไหม` | แสดงสต็อก 80 เส้น |
| `สั่งปูน 10 ถุง` | สรุปออเดอร์ รวม 1,450 บาท |
| `สวัสดี` | แสดง default menu |

---

## ✅ Checklist ผ่าน Week 2

```
□ bundle install — ไม่มี error
□ POST /webhook/line → Rails log แสดง request
□ LINE Verify Webhook → ✅ Success
□ พิมพ์ "ราคาปูน TPI" → บอทตอบราคาถูก
□ พิมพ์ "มีเหล็กไหม" → บอทตอบสต็อกถูก
□ พิมพ์ "สั่งปูน 10 ถุง" → บอทสรุปออเดอร์ถูก
□ มีสินค้าใน DB อย่างน้อย 8 รายการ
```

---

## ถัดไป Week 3
Payment QR PromptPay ผ่าน POSxPay
