# CLAUDE.md — ร้านบ้านสยาม LINE Bot

## Project Overview
Ruby on Rails LINE Bot สำหรับร้านค้าวัสดุก่อสร้าง "บ้านสยาม"
ลูกค้าสามารถค้นหาสินค้า เช็คราคา/สต็อก และสั่งซื้อผ่าน LINE ได้เลย

## Tech Stack
- **Rails 8** — API + LINE Webhook
- **LINE Messaging API v2** — line-bot-api gem
- **SQLite** — Cart system (local/Railway)
- **Node.js API** — Product database (Railway) เข้าถึงผ่าน `ActiveProductClient`
- **Deploy** — Railway

## Common Commands
```bash
# Start server
bundle exec rails server

# Run migrations
bundle exec rails db:migrate

# Open credentials
EDITOR="code --wait" bundle exec rails credentials:edit

# Show credentials
bundle exec rails credentials:show
```

## Architecture

### Controllers
- `LineBotController` — รับ LINE webhook, route events
- `SupplierLinesController` — web interface สำหรับผู้ค้า

### Concerns
- `app/controllers/concerns/line_bot_handler.rb` — handle LINE events ทุกประเภท
  - `handle_text_event(event)` — text messages
  - `handle_follow_event(event)` — เพิ่มเพื่อน
  - `handle_postback_event(event)` — button/quick reply actions

### Services
- `LineMessageBuilder` — สร้าง LINE message objects (Flex, Text, QuickReply)
- `MessageProductExtractor` — แยก intent + keyword จากข้อความลูกค้า
- `CartService` — จัดการตะกร้าสินค้า (ActiveRecord)
- `SupplierLineNotifier` — แจ้ง supplier เมื่อไม่พบสินค้า

### Models
- `ActiveProduct` — PORO ดึงข้อมูลสินค้าจาก Node.js API
- `Cart` — ตะกร้าสินค้า (status: active/processing)
- `CartItem` — รายการในตะกร้า

## ENV / Credentials
ใช้ **Rails credentials** (ไม่ใช้ ENV vars):
```ruby
Rails.application.credentials.channel_access_token  # LINE access token
Rails.application.credentials.channel_secret         # LINE channel secret
```

ENV vars ที่ยังใช้:
- `NODE_API_URL` — URL ของ Node.js product API
- `PRODUCT_API_KEY` — API key สำหรับ product API

## Postback Data Format
```
action=add_cart&sku=<product._id>
action=view_cart
action=clear_cart
action=process_order
```

## Cart Status
- `active` — ใช้งานได้ปกติ
- `processing` — กำลัง process order (ห้ามเพิ่มสินค้า/สั่งซื้อซ้ำ)

## Rules
- อย่าใช้ `ActiveProduct.where(...)` — ไม่ใช่ ActiveRecord ใช้ `ActiveProduct.search`, `ActiveProduct.search_by_barcode`, หรือ `ActiveProduct.all.find`
- Postback data ต้องไม่เกิน 300 bytes — ห้าม encode ชื่อสินค้าใน data
- Quick reply ใช้ `type: "postback"` ไม่ใส่ `text:` field เพื่อป้องกัน double-fire events
- LINE reply messages ได้สูงสุด 5 messages ต่อ 1 reply

## Roadmap
- [x] LINE Webhook + Bot Controller
- [x] Product Search + Flex Carousel
- [x] Cart System
- [ ] QR Payment via POSxPay
- [ ] PDF Quotation via Prawn
