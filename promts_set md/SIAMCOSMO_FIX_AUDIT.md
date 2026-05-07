# 🛠️ SiamCosmo — Fix Audit Findings
> Claude Code instruction file | พฤษภาคม 2568
> อ่านไฟล์นี้แล้วทำ Step 1–5 ตามลำดับ ห้ามข้ามขั้นตอน

---

## ⚠️ CONSTRAINTS (อ่านก่อนเริ่ม)

- ห้ามแตะ `baansiamdb` (production DB เดิม)
- ทุก collection ใหม่ใช้ `baansiam_cosmo` + `shop_id: 'shop_001'`
- ห้าม hardcode secret / token ใน code — ใช้ ENV เท่านั้น
- แก้ทีละ Step แล้ว report ก่อนไปขั้นต่อไป

---

## Step 1 — ลบ Fake Stats และ Mock Contractors

**เป้าหมาย:** หน้า landing page ต้องไม่มีตัวเลขโกหก เพราะทำลาย trust ลูกค้าจริง

### 1.1 ลบ fake stats ออกจาก landing page

เปิดไฟล์ `app/views/pages/home.html.erb` (หรือ root view ที่แสดงผล)

ลบหรือแทนที่ส่วนที่มี stats เหล่านี้:
- "10,000+ ผู้ใช้" → ลบออก หรือเปลี่ยนเป็นข้อความจริง เช่น "กำลังเปิดตัว"
- "500+ ร้านค้า" → ลบออก
- "4.9 คะแนน" → ลบออก
- "24/7" stat ที่เหลืออยู่ → ลบออก หรือแทนด้วย "ตอบกลับภายใน 1 ชั่วโมง" ถ้าทำได้จริง

แทนที่ด้วย social proof ที่จริง เช่น:
```erb
<p class="text-sm text-gray-500">
  บริการโดยทีมงานบ้านสยาม อยุธยา — ประสบการณ์กว่า 20 ปี
</p>
```

### 1.2 ลบ mock contractors

ตรวจสอบ seed file หรือ view ที่แสดง contractor badge "จำลอง":

```bash
grep -rn "จำลอง\|mock\|is_mock\|fake" app/views/ app/models/ db/seeds.rb --include="*.erb" --include="*.rb"
```

- ถ้ามีใน seed → comment ออกหรือลบ
- ถ้ามีใน view → ลบ badge "จำลอง" ออก หรือซ่อน section ทั้งหมดก่อน

**Report:** บอกว่าแก้ไฟล์ไหนบ้าง และ text ที่ลบออกคืออะไร

---

## Step 2 — แก้ Database Config (SQLite → PostgreSQL)

**เป้าหมาย:** production ต้องไม่ใช้ SQLite เพราะ Kamal/Docker ไม่ persistent

### 2.1 ตรวจสอบ config ปัจจุบัน

```bash
cat config/database.yml
cat .env 2>/dev/null | grep DATABASE
cat config/deploy.yml | grep -A5 "env:"
```

### 2.2 แก้ config/database.yml

ให้ production ใช้ `DATABASE_URL` จาก ENV:

```yaml
production:
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  url: <%= ENV["DATABASE_URL"] %>
```

### 2.3 แก้ config/deploy.yml — ลบ SQLite ENV

ใน `config/deploy.yml` ส่วน `env:` → ลบบรรทัดนี้ออก:
```yaml
DATABASE_URL: sqlite3:/rails/storage/production.sqlite3   # ลบบรรทัดนี้
```

แทนด้วย (ถ้า PostgreSQL อยู่บน Droplet เดียวกัน):
```yaml
DATABASE_URL: postgresql://postgres:PASSWORD@localhost/siamcosmo_production
```

หรือถ้าใช้ Railway PostgreSQL:
```yaml
DATABASE_URL: <%= ENV["DATABASE_URL"] %>
```

> ⚠️ ถ้าไม่มี PostgreSQL บน Droplet ให้หยุดตรงนี้และรายงาน — ต้อง setup DB ก่อน

### 2.4 ตรวจสอบ Gemfile

```bash
grep -n "sqlite\|pg\|postgres" Gemfile
```

ต้องมี:
```ruby
gem "pg", "~> 1.5"
```

ถ้ายังมี `gem "sqlite3"` อยู่ในกลุ่ม production ให้ย้ายไป development/test group:
```ruby
group :development, :test do
  gem "sqlite3", "~> 2.0"
end
```

**Report:** แสดง config ก่อน/หลังแก้

---

## Step 3 — เปิด LINE Bot Initializer

**เป้าหมาย:** ให้ LINE Bot ทำงานได้จริงบน production

### 3.1 ดู initializer ปัจจุบัน

```bash
cat config/initializers/line_bot.rb
```

### 3.2 เปิด comment ออก

ลบ `#` ที่ comment ไว้ออก แต่ต้องตรวจก่อนว่า ENV มีครบ:

```bash
# ตรวจว่า ENV ครบไหม
grep -rn "LINE_CHANNEL_SECRET\|LINE_CHANNEL_TOKEN\|LINE_CHANNEL_ACCESS_TOKEN" config/initializers/ config/credentials/ .env 2>/dev/null
```

ถ้า ENV ยังไม่มีใน deploy config:

```bash
cat config/deploy.yml | grep -A20 "env:"
```

เพิ่มใน `config/deploy.yml` ส่วน `env:` → `secret:`:
```yaml
env:
  secret:
    - LINE_CHANNEL_SECRET
    - LINE_CHANNEL_ACCESS_TOKEN
```

**Report:** แสดง initializer หลังแก้ และบอกว่า ENV set ไว้ที่ไหน

---

## Step 4 — สร้าง NodeApiClient Service

**เป้าหมาย:** ให้ Rails เรียก Node.js API ได้สำหรับดึงราคาสินค้าจริง

สร้างไฟล์ `app/services/node_api_client.rb`:

```ruby
# app/services/node_api_client.rb
# Service สำหรับเรียก Node.js API (Hostinger VPS)
# ใช้สำหรับดึงราคาสินค้าจริงจาก baansiamdb

class NodeApiClient
  BASE_URL = ENV.fetch("NODE_API_URL", "http://localhost:3001")
  API_KEY  = ENV.fetch("NODE_API_KEY", "")

  def self.get_product_prices(shop_id: "shop_001", category: nil)
    params = { shop_id: shop_id }
    params[:category] = category if category.present?

    response = make_request(
      method: :get,
      path:   "/api/products/prices",
      params: params
    )

    response&.dig("data") || fallback_prices
  rescue => e
    Rails.logger.error("[NodeApiClient] get_product_prices error: #{e.message}")
    fallback_prices
  end

  def self.get_product_by_slug(slug, shop_id: "shop_001")
    response = make_request(
      method: :get,
      path:   "/api/products/#{slug}",
      params: { shop_id: shop_id }
    )

    response&.dig("data")
  rescue => e
    Rails.logger.error("[NodeApiClient] get_product_by_slug error: #{e.message}")
    nil
  end

  private

  def self.make_request(method:, path:, params: {}, body: nil)
    uri = URI("#{BASE_URL}#{path}")
    uri.query = URI.encode_www_form(params) if method == :get && params.any?

    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 3
    http.read_timeout = 5

    request = case method
              when :get  then Net::HTTP::Get.new(uri)
              when :post then Net::HTTP::Post.new(uri)
              end

    request["Content-Type"]  = "application/json"
    request["x-api-key"]     = API_KEY
    request.body = body.to_json if body

    response = http.request(request)

    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      Rails.logger.warn("[NodeApiClient] #{method.upcase} #{path} → #{response.code}")
      nil
    end
  end

  # Fallback ราคาโดยประมาณ ถ้าเรียก Node.js ไม่ได้
  def self.fallback_prices
    {
      "cement_50kg"   => { price: 175,  unit: "ถุง",  name: "ปูนซีเมนต์ 50กก." },
      "sand_cubic"    => { price: 800,  unit: "คิว",  name: "ทรายหยาบ" },
      "gravel_cubic"  => { price: 900,  unit: "คิว",  name: "หินย่อย" },
      "rebar_12mm"    => { price: 185,  unit: "เส้น", name: "เหล็กเส้น 12มม." },
      "wiremesh_4mm"  => { price: 195,  unit: "แผ่น", name: "ตะแกรงลวด 4มม." },
      "brick_red"     => { price: 3.5,  unit: "ก้อน", name: "อิฐมอญ" },
      "tile_30x30"    => { price: 18,   unit: "แผ่น", name: "กระเบื้อง 30x30" }
    }
  end
end
```

### 4.1 เพิ่ม ENV ใน deploy config

เพิ่มใน `config/deploy.yml` ส่วน `env:`:
```yaml
env:
  clear:
    NODE_API_URL: http://YOUR_VPS_IP:3001
  secret:
    - NODE_API_KEY
```

แทนที่ `YOUR_VPS_IP` ด้วย IP จริงของ Hostinger VPS

### 4.2 ทดสอบ (ใน Rails console)

```bash
# rails console
NodeApiClient.get_product_prices(shop_id: "shop_001")
# ถ้า Node.js ไม่ได้รัน → ควรได้ fallback_prices กลับมา ไม่ crash
```

**Report:** แสดงผลจาก console test

---

## Step 5 — เพิ่ม webhook/:shop_id Route

**เป้าหมาย:** รองรับ multi-tenant LINE Bot (แต่ละร้านมี webhook URL ของตัวเอง)

### 5.1 ดู routes ปัจจุบัน

```bash
cat config/routes.rb
```

### 5.2 แก้ routes.rb

เพิ่ม route ใหม่ **คู่กัน** กับ route เดิม (อย่าลบ route เดิมก่อน):

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # Route เดิม (บ้านสยาม — ยังใช้งานได้)
  post "/webhook", to: "line_bot#callback"

  # Route ใหม่ — Multi-tenant (shop แต่ละร้าน)
  post "/webhook/:shop_id", to: "line_bot#callback"

  # ... routes อื่นๆ ที่มีอยู่แล้ว
end
```

### 5.3 แก้ LineBotController ให้รองรับ shop_id

เปิดไฟล์ `app/controllers/line_bot_controller.rb` แล้วแก้ใน action `callback`:

```ruby
def callback
  # รับ shop_id จาก URL params หรือ default เป็น shop_001
  @shop_id = params[:shop_id].presence || "shop_001"

  # ... code เดิมที่มีอยู่ ...
  # ทุกที่ที่ query MongoDB ต้องเพิ่ม shop_id:
  # เช่น: Product.where(shop_id: @shop_id).find_by(slug: slug)
end
```

> ⚠️ อย่าแก้ logic ภายใน callback มากกว่านี้ในครั้งเดียว — แค่เพิ่ม shop_id รับมาก่อน

**Report:** แสดง routes.rb หลังแก้ และ controller ส่วนที่เปลี่ยน

---

## ✅ Completion Checklist

หลังทำครบทุก Step ให้รายงานตารางนี้:

| Step | งาน | สถานะ | หมายเหตุ |
|------|-----|--------|---------|
| 1 | ลบ fake stats + mock contractors | ✅/❌ | |
| 2 | แก้ Database config → PostgreSQL | ✅/❌ | |
| 3 | เปิด LINE Bot initializer | ✅/❌ | |
| 4 | สร้าง NodeApiClient service | ✅/❌ | |
| 5 | เพิ่ม webhook/:shop_id route | ✅/❌ | |

และบอกว่า:
- มีไฟล์ไหนที่แก้แล้วอาจต้อง `kamal deploy` ใหม่บ้าง?
- มี ENV ไหนที่ต้อง set บน server ก่อน deploy?

---

## 🚀 วิธีใช้

```
อ่านไฟล์ SIAMCOSMO_FIX_AUDIT.md แล้วทำ Step 1-5 ตามลำดับ
รายงานผลแต่ละ Step ก่อนไปขั้นต่อไป
```

---

*SiamCosmo | Zayam | พฤษภาคม 2568*
