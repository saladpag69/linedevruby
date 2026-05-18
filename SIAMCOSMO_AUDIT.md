# 🔍 SiamCosmo — Project Audit Report

> Date: May 12, 2026
> Project: SiamCosmo / BuilderBot
> Stack: Rails 8.1.1 + LINE Bot API + Kamal (DigitalOcean)
> Server: `http://157.245.206.95`

---

## 📌 TASK 1 — Rails App Structure

| หัวข้อ | สถานะ | หมายเหตุ |
|--------|--------|----------|
| Calculator controller | ✅ | `app/controllers/calculator_controller.rb` (quick → step1–step4 → preview → pdf) |
| Calculator views | ✅ | 7 views: `quick`, `step1`, `step2`, `step3`, `step4`, `index`, `pdf` |
| PDF generation | ✅ | `wicked_pdf` + `app/views/calculator/pdf.html.erb` |
| NodeApiClient service | ❌ **ไม่มีไฟล์** | `app/services/node_api_client.rb` ไม่พบ — bridge ไป Node.js หาย |
| `/webhook/:shop_id` route | ❌ | มีแค่ `POST /line_bot/callback` เส้นทางเดียว |
| shop_id ใน LINE Bot | ❌ | LINE Bot controller **ไม่มี shop_id** — พบแค่ใน `SiamCosmoAuthService` |
| Fake stats ในหน้าเว็บ | ✅ **ลบแล้ว** | เหลือแค่ `placeholder` HTML attributes + CSS class name `phone-mockup` (ไม่ใช่ fake data) |
| Mock contractors | ⚠️ | `Contractor.available.mock.first(3)` ที่ `calculator_controller.rb:77` |
| LINE initializer | ❌ **Commented out** | `config/initializers/line_bot.rb` ทั้งไฟล์เป็น comment |
| Services (POROs) | ✅ | 10 ไฟล์ใน `app/services/` |
| Kamal deploy config | ✅ | `config/deploy.yml` → `157.245.206.95` |

**Files:**
- Controllers: 11 controllers + 1 concern (LineBotHandler)
- Models: 15 models
- Services: 10 services
- Views: 45+ `.erb` templates
- Migrations: 25 migrations

---

## 📌 TASK 2 — Database

| หัวข้อ | สถานะ | หมายเหตุ |
|--------|--------|----------|
| Production DB | ✅ PostgreSQL | `config/database.yml` ใช้ `DATABASE_URL` |
| Mongoid / MongoDB | ❌ **ไม่มี config** | ไม่มี `config/mongoid.yml` — ไม่เชื่อมต่อ MongoDB โดยตรง |
| baansiamdb (ห้ามแตะ) | ✅ **ปลอดภัย** | ไม่มี direct DB reference, ใช้ API endpoint เท่านั้น |
| Rails Models | ✅ | 15 models: User, Cart, CartItem, Orderable, Quote, QuoteMaterial, Contractor, Provider, ServiceType, CalculatorService, ChatSession, Message, CommunicateService, ActiveProduct, ApplicationRecord |

**Migrations (25, sorted by date):**
```
20250407143000  CreateUsers
20260119083926  CreateProducts
20260119083933  CreateCarts
20260119084109  CreateModels
20260119085315  CreateServices
20260119085538  CreateOrderables
20260120000001  AddLineUserIdAndExpiresAtToCarts
20260120000002  CreateCartItems
20260324082046  AddStatusToCarts
20260325000001  AddUniqueIndexActiveCartPerUser
20260411072446  AddDeviseToUsers
20260411072526  CreateProviders
20260411072541  CreateChatSessions
20260411072601  CreateMessages
20260411072620  UpdateServicesForSiamcosmo
20260411074152  AddSessionKeyToChatSessions
20260411074310  MakeUserIdNullableInChatSessions
20260413000001  CreateServiceTypes
20260413000002  CreateContractors
20260413000003  CreateQuotes
20260413000004  CreateQuoteMaterials
20260414041922  AddImageToProviders
20260421000001  RenameServicesCreateCalculatorServices
```

---

## 📌 TASK 3 — Calculator Feature

**Work Types ที่รองรับ:**
| ประเภทงาน | สถานะ |
|-----------|--------|
| เทพื้น (concrete_floor) | ✅ |
| ก่ออิฐ (brick_wall) | ✅ |
| ปูกระเบื้อง (tile_floor) | ✅ |
| ฉาบปูน (plaster / paint_wall) | ✅ |
| งานระบบไฟฟ้า (electrical) | ✅ |
| งานประปา (plumbing) | ✅ |
| โซล่าเซลล์ (solar) | ✅ |
| กล้องวงจรปิด (cctv) | ✅ |
| ประตูอัตโนมัติ (autodoor) | ✅ |

**ราคา:**
- Config-based hardcoded (ใน `calculator_controller.rb`: concrete grades, labor rate, mesh price)
- Cache จาก Baansiam API (`baansiam_prices`) สำหรับวัสดุ
- **ไม่มีการเรียก Node.js โดยตรง**

**Construction Formulas (`app/services/construction_formulas.rb`):**
- `calculate_concrete_floor`
- `calculate_tile`
- `calculate_aac_wall`
- `calculate_concrete_column`

**PDF:** ✅ Generate ผ่าน `wicked_pdf` (`app/views/calculator/pdf.html.erb`)

**Stimulus JS:** ✅ `app/javascript/controllers/calculator_controller.js`

---

## 📌 TASK 4 — LINE Bot

| หัวข้อ | สถานะ | หมายเหตุ |
|--------|--------|----------|
| LINE initializer | ❌ **Commented out** | `config/initializers/line_bot.rb` ทั้งไฟล์เป็น comment (`require "line/bot"` → `Line::Bot::Client`) |
| LINE Bot controller | ✅ | ใช้ `Line::Bot::V2` API โดยตรง (bypass initializer) |
| Webhook route | ✅ | `POST /line_bot/callback` |
| shop_id support | ❌ | ไม่มี multi-tenant routing |
| Event types รองรับ | ✅ | message, follow, unfollow, postback |
| Supplier Group | ✅ | `SUPPLIER_GROUP_ID` hardcoded |

**ENV ที่ LINE Bot ใช้:**
| Key | บน Server? | หมายเหตุ |
|-----|-----------|----------|
| `CHANNEL_ACCESS_TOKEN` | ❌ **ไม่มี** | ต้อง set ก่อน deploy container ใหม่ |
| `CHANNEL_SECRET` | ❌ **ไม่มี** | ต้อง set ก่อน deploy container ใหม่ |
| `SIAMCOSMO_BASE_URL` | ❌ **ไม่มี** | default: `http://localhost:5001` |
| `SIAMCOSMO_STATIC_TOKEN` | ❌ **ไม่มี** | fallback to hardcoded token |
| `SIAMCOSMO_SHOP_ID` | ❌ **ไม่มี** | fallback: `branch_001` |
| `PRODUCT_API_KEY` | ❌ **ไม่มี** | fallback to unauthenticated |

---

## 📌 TASK 5 — Deploy Status

| หัวข้อ | สถานะ | รายละเอียด |
|--------|--------|------------|
| Server IP | ✅ | `157.245.206.95` (DigitalOcean Droplet, SGP1) |
| Health check | ✅ | `GET /up` → 200 OK |
| App running | ✅ | Container `siamcosmo-web-2e4a...` (อาย 2 สัปดาห์) |
| Railway PostgreSQL | ❌ **ยังไม่ได้ deploy** | Container เก่ายังใช้ Supabase config เก่า |
| Git uncommitted | ⚠️ | 2 files: `construction_formulas.rb`, `quote_calculator_service.rb` |
| Latest commit | | `f8e5434 Step 2: Switch to Railway PostgreSQL` |
| SSL | ❌ ปิดอยู่ | `proxy.ssl: false` — ใช้ IP ไม่มี domain |

**Kamal Deploy Config:**
- Registry: `registry-1.docker.io` (docker.io)
- Image: `zayam/siamcosmodigital`
- Server: `157.245.206.95`
- DATABASE_URL: Railway PostgreSQL (internal URL — `.railway.internal`)
- Port: 80
- Deploy timeout: 300s

**Deploy Issue:** Docker Hub login fails intermittently (`EOF` network error) → deploy ไม่สำเร็จ

---

## 📊 Summary Table

```
| หัวข้อ                          | สถานะ      | หมายเหตุ                       |
|---------------------------------|-----------|-------------------------------|
| Calculator controller           | ✅         | 9 ประเภทงาน, 7 views          |
| Quote PDF service               | ✅         | wicked_pdf                     |
| NodeApiClient service           | ❌         | bridge ไป Node.js หาย         |
| /webhook/:shop_id route         | ❌         | มีแค่ /line_bot/callback      |
| shop_id ใน LineBotController    | ❌         | ไม่มี multi-tenant             |
| Fake stats ในหน้าเว็บ           | ✅ ลบแล้ว  | placeholder HTML ไม่นับ       |
| Mock contractors                | ⚠️         | calculator_controller.rb:77   |
| Database: PostgreSQL            | ✅         | ผ่าน DATABASE_URL ENV          |
| Mongoid ชี้ไป baansiam_cosmo    | ❌         | ไม่มี Mongoid config           |
| baansiamdb (ห้ามแตะ)            | ✅ ปลอดภัย | เชื่อมต่อผ่าน API เท่านั้น      |
| LINE Bot initializer            | ❌         | commented out                  |
| ENV on server                   | ⚠️         | ขาด 6 keys ที่จำเป็น           |
| Kamal deploy config             | ✅         | 157.245.206.95 (disabled SSL)  |
| Git uncommitted changes         | ⚠️ dirty   | 2 files                        |
```

---

## 🚀 สรุป 3 ข้อที่ต้องทำต่อ

### 1️⃣ Set ENV variables บน Server (ก่อน deploy)
```
CHANNEL_ACCESS_TOKEN=...       # LINE Messaging API
CHANNEL_SECRET=...             # LINE Channel Secret
SIAMCOSMO_BASE_URL=...         # http://localhost:5001 หรือ production URL
SIAMCOSMO_STATIC_TOKEN=...     # auth token
SIAMCOSMO_SHOP_ID=branch_001   # หรือค่าจริง
PRODUCT_API_KEY=...            # API key สำหรับ ActiveProduct
```

### 2️⃣ Deploy container ใหม่ (Railway PostgreSQL)
- Fix Docker Hub login issue (retry / ใช้ ghcr.io แทน)
- `bin/kamal deploy` หรือ push image + pull ตรงบน server

### 3️⃣ ลบ Mock Contractors
- `calculator_controller.rb:77` — `Contractor.available.mock.first(3)`
- ใช้ data-driven approach แทน mock fallback

---

*SiamCosmo | Zayam | May 2026*
*Deploy: DigitalOcean + Kamal | http://157.245.206.95*
