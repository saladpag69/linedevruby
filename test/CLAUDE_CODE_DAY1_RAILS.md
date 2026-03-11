# BuilderBot — Rails Credentials Setup
> Day 1 | Ruby on Rails only | BuilderBot LINE Bot

---

## 🎯 งานที่ต้องทำ
ย้าย API Keys ออกจาก source code ไปเก็บใน Rails credentials

---

## 🔴 ปัญหา — secrets อยู่ใน code ตรงๆ

### ไฟล์ที่ 1: `app/controllers/line_bot_controller.rb`
```ruby
# บรรทัดที่มีปัญหา
channel_access_token: "5rc4Avbnsgnm7U1F/Ok1y..."
channel_secret: "2f93e390fa625b298c1278286de6f167"
```

### ไฟล์ที่ 2: `app/services/Nlu/llm_engine.rb`
```ruby
# บรรทัดที่มีปัญหา
api_key: "sk-proj-rzmtCFM5gmY7..."
```

---

## ✅ Tasks

### Task 1 — แก้ line_bot_controller.rb

ค้นหาและแทนที่:

```ruby
# เดิม
channel_access_token: "5rc4Avbnsgnm7U1F/Ok1y...",

# ใหม่
channel_access_token: Rails.application.credentials.line[:channel_access_token],
```

```ruby
# เดิม
channel_secret: "2f93e390fa625b298c1278286de6f167"

# ใหม่
channel_secret: Rails.application.credentials.line[:channel_secret]
```

---

### Task 2 — แก้ llm_engine.rb

ค้นหาและแทนที่:

```ruby
# เดิม
openai = OpenAI::Client.new(
  api_key: "sk-proj-rzmtCFM5gmY7..."
)

# ใหม่
openai = OpenAI::Client.new(
  api_key: Rails.application.credentials.openai[:api_key]
)
```

---

### Task 3 — เพิ่มข้อมูลใน Rails credentials

รันคำสั่งนี้ใน terminal:
```bash
EDITOR="nano" rails credentials:edit
```

เพิ่มข้อมูลนี้ในไฟล์ที่เปิดขึ้นมา:
```yaml
line:
  channel_access_token: "ใส่ token จริง"
  channel_secret: "ใส่ secret จริง"

openai:
  api_key: "sk-proj-..."

node:
  internal_api_key: "ค่าเดียวกับ INTERNAL_API_KEY ใน Node.js .env"
  base_url: "http://localhost:5001"
```

บันทึกและปิด → `Ctrl+X` → `Y` → `Enter`

---

### Task 4 — ตรวจสอบ .gitignore

ไฟล์ `.gitignore` ต้องมีบรรทัดเหล่านี้:
```
config/master.key
config/credentials/*.key
```

---

### Task 5 — Verify

```bash
# ตรวจสอบว่าไม่มี secret หลุดใน code
grep -r "sk-proj" app/ --include="*.rb"
grep -r "channel_access_token.*ey" app/ --include="*.rb"

# ทั้งสองคำสั่งต้องไม่พบผลลัพธ์ใดๆ

# ทดสอบว่า Rails ยัง start ได้ปกติ
rails server
```

---

## ✅ เกณฑ์ผ่าน

```
□ rails server → Listening on http://localhost:3000
□ grep "sk-proj" app/ → ไม่พบ
□ grep "channel_access_token.*ey" app/ → ไม่พบ
□ config/master.key อยู่ใน .gitignore
```
