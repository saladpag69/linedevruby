puts "Seeding Calculator data..."

ServiceType.destroy_all
Contractor.destroy_all

ServiceType.create!(
  slug: "concrete_floor",
  icon: "🧱",
  name_th: "เทพื้นคอนกรีต",
  name_en: "Concrete Floor",
  name_zh: "混凝土地面",
  inputs: [
    { "key" => "width", "label" => "ความกว้าง", "unit" => "เมตร", "type" => "number" },
    { "key" => "length", "label" => "ความยาว", "unit" => "เมตร", "type" => "number" },
    { "key" => "thickness", "label" => "ความหนา", "unit" => "เมตร", "type" => "number", "default" => 0.10 }
  ],
  formula: "width * length * thickness",
  materials: [
    { "product_slug" => "cement_50kg", "qty_formula" => "volume * 6.5", "unit" => "ถุง" },
    { "product_slug" => "sand", "qty_formula" => "volume * 1.2", "unit" => "ครึ่งกระบะ" },
    { "product_slug" => "gravel", "qty_formula" => "volume * 1.3", "unit" => "ครึ่งคัน" }
  ],
  labor_rate_per_sqm: 150,
  labor_unit: "ตร.ม.",
  sort_order: 1
)

ServiceType.create!(
  slug: "paint_wall",
  icon: "🎨",
  name_th: "ทาสีบ้าน",
  name_en: "Wall Painting",
  name_zh: "墙面油漆",
  inputs: [
    { "key" => "width", "label" => "ความกว้าง", "unit" => "เมตร", "type" => "number" },
    { "key" => "length", "label" => "ความยาว", "unit" => "เมตร", "type" => "number" },
    { "key" => "height", "label" => "ความสูง", "unit" => "เมตร", "type" => "number", "default" => 2.5 }
  ],
  formula: "width * length",
  materials: [
    { "product_slug" => "paint", "qty_formula" => "area * 0.35", "unit" => "แกลลอน" },
    { "product_slug" => "paint_primer", "qty_formula" => "area * 0.25", "unit" => "แกลลอน" }
  ],
  labor_rate_per_sqm: 80,
  labor_unit: "ตร.ม.",
  sort_order: 2
)

ServiceType.create!(
  slug: "tile_floor",
  icon: "🔲",
  name_th: "วางกระเบื้อง",
  name_en: "Floor Tiling",
  name_zh: "铺设瓷砖",
  inputs: [
    { "key" => "width", "label" => "ความกว้าง", "unit" => "เมตร", "type" => "number" },
    { "key" => "length", "label" => "ความยาว", "unit" => "เมตร", "type" => "number" }
  ],
  formula: "width * length",
  materials: [
    { "product_slug" => "tile_60x60", "qty_formula" => "area * 2.8", "unit" => "แผ่น" }
  ],
  labor_rate_per_sqm: 180,
  labor_unit: "ตร.ม.",
  sort_order: 3
)

ServiceType.create!(
  slug: "brick_wall",
  icon: "🧱",
  name_th: "ก่อผนังอิฐ",
  name_en: "Brick Wall",
  name_zh: "砖墙",
  inputs: [
    { "key" => "width", "label" => "ความกว้าง", "unit" => "เมตร", "type" => "number" },
    { "key" => "height", "label" => "ความสูง", "unit" => "เมตร", "type" => "number" },
    { "key" => "thickness", "label" => "ความหนา", "unit" => "เมตร", "type" => "number", "default" => 0.14 }
  ],
  formula: "width * height * thickness",
  materials: [
    { "product_slug" => "cement_block", "qty_formula" => "area * 60", "unit" => "ก้อน" },
    { "product_slug" => "cement_50kg", "qty_formula" => "volume * 5", "unit" => "ถุง" },
    { "product_slug" => "sand", "qty_formula" => "volume * 0.5", "unit" => "ครึ่งกระบะ" }
  ],
  labor_rate_per_sqm: 120,
  labor_unit: "ตร.ม.",
  sort_order: 4
)

ServiceType.create!(
  slug: "plumbing",
  icon: "🚰",
  name_th: "งานประปา",
  name_en: "Plumbing",
  name_zh: "水管工程",
  inputs: [
    { "key" => "length", "label" => "ระยะทาง", "unit" => "เมตร", "type" => "number" },
    { "key" => "height", "label" => "จำนวนจุด", "unit" => "จุด", "type" => "number", "default" => 1 }
  ],
  formula: "length",
  materials: [],
  labor_rate_per_sqm: 250,
  labor_unit: "จุด",
  sort_order: 5
)

ServiceType.create!(
  slug: "electrical",
  icon: "💡",
  name_th: "งานไฟฟ้า",
  name_en: "Electrical",
  name_zh: "电气工程",
  inputs: [
    { "key" => "length", "label" => "ระยะทาง", "unit" => "เมตร", "type" => "number" },
    { "key" => "height", "label" => "จำนวนจุด", "unit" => "จุด", "type" => "number", "default" => 1 }
  ],
  formula: "length",
  materials: [],
  labor_rate_per_sqm: 300,
  labor_unit: "จุด",
  sort_order: 6
)
# === NEW: Solar ===
ServiceType.create!(
  slug: "solar",
  icon: "☀️",
  name_th: "โซล่าเซลล์",
  name_en: "Solar Cell",
  inputs: [
    { "key" => "kw", "label" => "ขนาดระบบ", "unit" => "kW", "type" => "select",
      "options" => [ { "value" => 3, "label" => "3 kW" }, { "value" => 5, "label" => "5 kW" },
                     { "value" => 10, "label" => "10 kW" }, { "value" => 15, "label" => "15 kW" } ] },
    { "key" => "inverter", "label" => "ยี่ห้ออินเวอร์เตอร์", "type" => "select",
      "options" => [ { "value" => "psi", "label" => "PSI", "price" => 18000 },
                     { "value" => "deye", "label" => "DEYE", "price" => 19000 },
                     { "value" => "huawei", "label" => "HUAWEI", "price" => 25000 } ] }
  ],
  materials: [
    { "product_slug" => "solar_panel", "qty_formula" => "kw * 1000 / 550", "unit" => "แผง", "price_per_unit" => 6 },
    { "product_slug" => "inverter", "qty_formula" => "1", "unit" => "ตัว", "price_from_input" => "inverter" },
    { "product_slug" => "mounting", "qty_formula" => "kw * 1000 / 550", "unit" => "ชุด", "price" => 1500 },
    { "product_slug" => "pv_cable", "qty_formula" => "kw * 4", "unit" => "มม.", "price" => 50 }
  ],
  labor_rate_per_watt: 5,
  labor_unit: "วัตต์",
  sort_order: 7
)

# === NEW: CCTV ===
ServiceType.create!(
  slug: "cctv",
  icon: "📹",
  name_th: "กล้องวงจรปิด",
  inputs: [
    { "key" => "cameras", "label" => "จำนวนกล้อง", "unit" => "ตัว", "type" => "number", "min" => 1, "max" => 8 },
    { "key" => "resolution", "label" => "ความละเอียด", "type" => "select",
      "options" => [ { "value" => 1, "label" => "1 MP" }, { "value" => 2, "label" => "2 MP" },
                     { "value" => 4, "label" => "4 MP" }, { "value" => 6, "label" => "6 MP" } ] }
  ],
  materials: [
    { "product_slug" => "ip_camera", "qty_formula" => "cameras", "unit" => "ตัว", "price" => 1500 },
    { "product_slug" => "storage", "qty_formula" => "cameras >= 4 ? 1 : 0", "unit" => "ชุด", "price" => 5000 },
    { "product_slug" => "sd_card", "qty_formula" => "cameras < 4 ? cameras : 0", "unit" => "ใบ", "price" => 500 },
    { "product_slug" => "lan_cable", "qty_formula" => "ceil(cameras * 20)", "unit" => "มม.", "price" => 50 },
    { "product_slug" => "electrical", "qty_formula" => "cameras", "unit" => "จุด", "price" => 300 }
  ],
  labor_rate_per_sqm: 800,
  labor_unit: "จุด",
  sort_order: 8
)

# === NEW: AutoDoor ===
ServiceType.create!(
  slug: "autodoor",
  icon: "🚪",
  name_th: "ประตูอัตโนมัติ",
  name_en: "Auto Gate",
  inputs: [
    { "key" => "weight", "label" => "น้ำหนักประตู", "unit" => "kg", "type" => "select",
      "options" => [ { "value" => 1000, "label" => "1,000 kg" }, { "value" => 1500, "label" => "1,500 kg" },
                     { "value" => 2000, "label" => "2,000 kg" }, { "value" => 3000, "label" => "3,000 kg" } ] }
  ],
  materials: [
    { "product_slug" => "motor", "qty_formula" => "1", "unit" => "ตัว", "price" => 16000 },
    { "product_slug" => "rail", "qty_formula" => "1", "unit" => "ชุด", "price" => 3000 },
    { "product_slug" => "remote", "qty_formula" => "2", "unit" => "ตัว", "price" => 500 },
    { "product_slug" => "sensor", "qty_formula" => "1", "unit" => "ชุด", "price" => 1500 }
  ],
  labor_rate_per_sqm: 5000,
  labor_unit: "ตัว",
  sort_order: 9
)

puts "Created #{ServiceType.count} service types"

Contractor.create!(
  name: "ช่างสมชาย (จำลอง)",
  rating: 4.8,
  experience_years: 8,
  service_type_slugs: [ "concrete_floor", "brick_wall", "tile_floor" ],
  rate_per_sqm: 150,
  available: true,
  is_mock: true,
  description: "ช่างผู้มีประสบการณ์ในงานก่อสร้างและตกแต่งบ้านกว่า 8 ปี"
)

Contractor.create!(
  name: "ช่างสมใจ (จำลอง)",
  rating: 4.5,
  experience_years: 5,
  service_type_slugs: [ "paint_wall", "tile_floor" ],
  rate_per_sqm: 120,
  available: true,
  is_mock: true,
  description: "ช่างทาสีและปูกระเบื้องมืออาชีพ"
)

Contractor.create!(
  name: "ช่างเจริญ (จำลอง)",
  rating: 4.9,
  experience_years: 12,
  service_type_slugs: [ "concrete_floor", "brick_wall", "plumbing", "electrical" ],
  rate_per_sqm: 200,
  available: true,
  is_mock: true,
  description: "ช่างผู้เชี่ยวชาญด้านงานระบบ"
)

puts "Created #{Contractor.count} contractors"
puts "Calculator seeding completed!"
