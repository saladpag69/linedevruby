# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_14_041922) do
  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.datetime "created_at", null: false
    t.decimal "price", precision: 10, scale: 2
    t.string "product_name"
    t.integer "quantity", default: 1
    t.string "sku"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "line_user_id"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["line_user_id"], name: "index_carts_active_unique_user", unique: true, where: "status = 'active'"
    t.index ["line_user_id"], name: "index_carts_on_line_user_id"
  end

  create_table "chat_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "service_id", null: false
    t.string "session_key"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["service_id"], name: "index_chat_sessions_on_service_id"
    t.index ["session_key"], name: "index_chat_sessions_on_session_key"
    t.index ["status"], name: "index_chat_sessions_on_status"
    t.index ["user_id"], name: "index_chat_sessions_on_user_id"
  end

  create_table "contractors", force: :cascade do |t|
    t.boolean "available", default: true
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "experience_years", default: 0
    t.string "image_url"
    t.boolean "is_mock", default: false
    t.string "line_id"
    t.string "name", null: false
    t.string "phone"
    t.decimal "rate_per_sqm", precision: 10, scale: 2, default: "0.0"
    t.decimal "rating", precision: 2, scale: 1, default: "0.0"
    t.json "service_type_slugs", default: []
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer "chat_session_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.boolean "read", default: false
    t.string "role", null: false
    t.json "suggestions"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["chat_session_id"], name: "index_messages_on_chat_session_id"
    t.index ["role"], name: "index_messages_on_role"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "models", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.datetime "created_at", null: false
    t.string "orderable"
    t.integer "product_id", null: false
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_models_on_cart_id"
    t.index ["product_id"], name: "index_models_on_product_id"
  end

  create_table "orderables", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.datetime "created_at", null: false
    t.integer "quantity"
    t.integer "service_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_orderables_on_cart_id"
    t.index ["service_id"], name: "index_orderables_on_service_id"
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "descriotion"
    t.string "name"
    t.decimal "proce", precision: 5, scale: 2
    t.datetime "updated_at", null: false
  end

  create_table "providers", force: :cascade do |t|
    t.string "address"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.integer "jobs_completed", default: 0
    t.string "line_id"
    t.string "phone"
    t.decimal "rating", precision: 2, scale: 1, default: "0.0"
    t.integer "service_id", null: false
    t.string "status", default: "open"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.boolean "verified", default: false
    t.json "work_types"
    t.index ["service_id"], name: "index_providers_on_service_id"
    t.index ["status"], name: "index_providers_on_status"
    t.index ["user_id"], name: "index_providers_on_user_id"
    t.index ["verified"], name: "index_providers_on_verified"
  end

  create_table "quote_materials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "product_name", null: false
    t.string "product_slug", null: false
    t.integer "quantity", default: 0
    t.integer "quote_id", null: false
    t.string "shop_id", default: "branch_001"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0"
    t.string "unit", default: "ชิ้น"
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.index ["quote_id", "product_slug"], name: "index_quote_materials_on_quote_id_and_product_slug"
    t.index ["quote_id"], name: "index_quote_materials_on_quote_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.decimal "area", precision: 10, scale: 2, default: "0.0"
    t.integer "contractor_id"
    t.datetime "created_at", null: false
    t.decimal "delivery_fee", precision: 10, scale: 2, default: "0.0"
    t.string "delivery_option", default: "pickup"
    t.decimal "grand_total", precision: 10, scale: 2, default: "0.0"
    t.json "inputs", default: {}
    t.decimal "labor_total", precision: 10, scale: 2, default: "0.0"
    t.string "line_user_id"
    t.decimal "material_total", precision: 10, scale: 2, default: "0.0"
    t.text "note"
    t.string "pdf_url"
    t.integer "service_type_id", null: false
    t.string "session_key"
    t.json "shop_prices", default: {}
    t.string "status", default: "draft"
    t.decimal "tax", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.decimal "volume", precision: 10, scale: 2, default: "0.0"
    t.index ["contractor_id"], name: "index_quotes_on_contractor_id"
    t.index ["line_user_id"], name: "index_quotes_on_line_user_id"
    t.index ["service_type_id"], name: "index_quotes_on_service_type_id"
    t.index ["session_key"], name: "index_quotes_on_session_key"
    t.index ["status"], name: "index_quotes_on_status"
    t.index ["user_id"], name: "index_quotes_on_user_id"
  end

  create_table "service_types", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.string "formula", null: false
    t.string "icon", default: "🔧"
    t.json "inputs", default: []
    t.decimal "labor_rate_per_sqm", precision: 10, scale: 2, default: "0.0"
    t.string "labor_unit", default: "ตร.ม."
    t.json "materials", default: []
    t.string "name_en"
    t.string "name_th", null: false
    t.string "name_zh"
    t.string "slug", null: false
    t.integer "sort_order", default: 0
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_service_types_on_slug", unique: true
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.text "greeting_message"
    t.string "icon"
    t.boolean "is_active", default: true
    t.string "key"
    t.string "name"
    t.string "name_en"
    t.string "name_th"
    t.string "name_zh"
    t.decimal "price", precision: 5, scale: 2
    t.json "suggestions"
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_services_on_is_active"
    t.index ["key"], name: "index_services_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email"
    t.string "encrypted_password"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "line_display_name"
    t.string "line_id"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "user"
    t.string "shop_id", default: "branch_001"
    t.string "siamcosmo_token"
    t.string "siamcosmo_user_id"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email"
    t.index ["line_id"], name: "index_users_on_line_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["siamcosmo_user_id"], name: "index_users_on_siamcosmo_user_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "cart_items", "carts"
  add_foreign_key "chat_sessions", "services"
  add_foreign_key "chat_sessions", "users"
  add_foreign_key "messages", "chat_sessions"
  add_foreign_key "messages", "users"
  add_foreign_key "models", "carts"
  add_foreign_key "models", "products"
  add_foreign_key "orderables", "carts"
  add_foreign_key "orderables", "services"
  add_foreign_key "providers", "services"
  add_foreign_key "providers", "users"
  add_foreign_key "quote_materials", "quotes"
  add_foreign_key "quotes", "contractors"
  add_foreign_key "quotes", "service_types"
  add_foreign_key "quotes", "users"
end
