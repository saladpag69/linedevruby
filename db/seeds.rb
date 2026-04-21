# Communicate Services (LINE Bot) Seed
communicate_services = [
  {
    key: "calculator",
    name_th: "เครื่องคำนวณวัสดุ",
    name_en: "Material Calculator",
    name_zh: "材料计算器",
    icon: "🧮",
    greeting_message_th: "สวัสดิครับ! ผมช่วยคุณคำนวณวัสดุก่อสร้าง\n\nเลือกรูปร่างพื้นที่แล้วกรอกขนาด:",
    greeting_message_en: "Hello! I can help you calculate construction materials.\n\nSelect a shape and enter dimensions:",
    greeting_message_zh: "你好! 我可以帮你计算建筑材料。\n\n选择形状并输入尺寸:",
    suggestions: [
      { th: "คำนวณพื้นที่", en: "Calculate Area", zh: "计算面积" },
      { th: "คำนวณผนัง", en: "Calculate Wall", zh: "计算墙壁" },
      { th: "คำนวณคอนกรีต", en: "Calculate Concrete", zh: "计算混凝土" },
      { th: "ดูรายการ", en: "View List", zh: "查看列表" }
    ]
  },
  {
    key: "price",
    name_th: "ราคาวัสดุ",
    name_en: "Material Prices",
    name_zh: "材料价格",
    icon: "💰",
    greeting_message_th: "เปรียบเทียบราคาวัสดุจากหลายร้านค้า",
    greeting_message_en: "Compare material prices from multiple stores",
    greeting_message_zh: "比较多家商店的材料价格",
    suggestions: [
      { th: "ดูราคาวัสดุ", en: "View Prices", zh: "查看价格" },
      { th: "ค้นหาสินค้า", en: "Search Products", zh: "搜索产品" },
      { th: "เปรียบเทียบราคา", en: "Compare Prices", zh: "比较价格" },
      { th: "ติดต่อร้าน", en: "Contact Store", zh: "联系商店" }
    ]
  },
  {
    key: "contractor",
    name_th: "ผู้รับเหมา",
    name_en: "Contractors",
    name_zh: "承包商",
    icon: "👷",
    greeting_message_th: "หาช่างและทีมรับเหมาจากชุมชน",
    greeting_message_en: "Find builders and contractor teams from the community",
    greeting_message_zh: "寻找社区的建筑商和承包团队",
    suggestions: [
      { th: "ค้นหาผู้รับเหมา", en: "Search Contractors", zh: "搜索承包商" },
      { th: "ดูผลงาน", en: "View Portfolio", zh: "查看作品集" },
      { th: "ขอใบเสนอราคา", en: "Request Quote", zh: "请求报价" },
      { th: "ติดต่อผู้รับเหมา", en: "Contact Contractor", zh: "联系承包商" }
    ]
  },
  {
    key: "transport",
    name_th: "ขนส่งวัสดุ",
    name_en: "Material Transport",
    name_zh: "材料运输",
    icon: "🚚",
    greeting_message_th: "บริการขนส่งวัสดุก่อสร้าง",
    greeting_message_en: "Construction material transport services",
    greeting_message_zh: "建筑材料运输服务",
    suggestions: [
      { th: "ขอใบเสนอราคา", en: "Request Quote", zh: "请求报价" },
      { th: "เปรียบเทียข่าบริการ", en: "Compare Rates", zh: "比较费用" },
      { th: "ติดต่อผู้ให้บริการ", en: "Contact Provider", zh: "联系服务商" },
      { th: "ดูรายการ", en: "View List", zh: "查看列表" }
    ]
  },
  {
    key: "rental",
    name_th: "เช่าเครื่องมือ",
    name_en: "Equipment Rental",
    name_zh: "设备租赁",
    icon: "🔧",
    greeting_message_th: "เช่าเครื่องมือและเครื่องจักรก่อสร้าง",
    greeting_message_en: "Rent construction tools and machinery",
    greeting_message_zh: "租赁建筑工具和机械设备",
    suggestions: [
      { th: "ดูเครื่องมือ", en: "View Equipment", zh: "查看设备" },
      { th: "ขอใบเสนอราคา", en: "Request Quote", zh: "请求报价" },
      { th: "เช่าอุปกรณ์", en: "Rent Equipment", zh: "租赁设备" },
      { th: "ติดต่อผู้ให้บริการ", en: "Contact Provider", zh: "联系服务商" }
    ]
  },
  {
    key: "projects",
    name_th: "ผลงาน",
    name_en: "Portfolio",
    name_zh: "作品集",
    icon: "🏗️",
    greeting_message_th: "ดูผลงานจากช่างและผู้รับเหมา",
    greeting_message_en: "View builders and contractor portfolios",
    greeting_message_zh: "查看建筑商和承包商的作品集",
    suggestions: [
      { th: "ดูผลงาน", en: "View Projects", zh: "查看项目" },
      { th: "ค้นหาตามประเภท", en: "Search by Type", zh: "按类型搜索" },
      { th: "ติดต่อผู้รับเหมา", en: "Contact Contractor", zh: "联系承包商" },
      { th: "ดูรายการ", en: "View List", zh: "查看列表" }
    ]
  },
  {
    key: "documents",
    name_th: "เอกสาร",
    name_en: "Documents",
    name_zh: "文档",
    icon: "📄",
    greeting_message_th: "คลังเอกสารสำหรับบ้านและก่อสร้าง",
    greeting_message_en: "Document warehouse for home and construction",
    greeting_message_zh: "房屋和建筑文档仓库",
    suggestions: [
      { th: "ค้นหาเอกสาร", en: "Search Documents", zh: "搜索文档" },
      { th: "ใบขออนุญาต", en: "Permit Application", zh: "许可申请" },
      { th: "สัญญา/ข้อตกลง", en: "Contracts", zh: "合同/协议" },
      { th: "ดาวน์เอกสาร", en: "Download", zh: "下载" }
    ]
  }
]

communicate_services.each do |s|
  CommunicateService.find_or_create_by!(key: s[:key]) do |service|
    service.name_th = s[:name_th]
    service.name_en = s[:name_en]
    service.name_zh = s[:name_zh]
    service.icon = s[:icon]
    service.greeting_message = s[:greeting_message_th]
    service.suggestions = s[:suggestions]
    service.is_active = true
    puts "Created CommunicateService: #{s[:name_th]}"
  end
end

puts "✅ Communicate Services seeded: #{CommunicateService.count}"

# Calculator Services (Tabs) Seed
calculator_services = [
  {
    slug: "construction",
    name_th: "งานก่อสร้าง",
    name_en: "Construction",
    icon: "🏗️",
    sort_order: 1,
    input_fields: [
      { key: "width", label_th: "กว้าง (เมตร)", label_en: "Width (m)", type: "number" },
      { key: "length", label_th: "ยาว (เมตร)", label_en: "Length (m)", type: "number" },
      { key: "thickness", label_th: "สูง/หนา (เมตร)", label_en: "Height/Thickness (m)", type: "number" },
      { key: "work_type", label_th: "ประเภทงาน", label_en: "Work Type", type: "select" },
      { key: "concrete_grade", label_th: "เกรดคอนกรีต", label_en: "Concrete Grade", type: "select" }
    ],
    presets: [
      { slug: "floor", name_th: "เทพื้น", name_en: "Pour Floor" },
      { slug: "plaster", name_th: "ฉาบผนัง", name_en: "Plaster Wall" },
      { slug: "tile", name_th: "ปูกระเบื้อง", name_en: "Lay Tile" },
      { slug: "beam", name_th: "เทคาน", name_en: "Pour Beam" }
    ]
  },
  {
    slug: "electrical",
    name_th: "ช่างไฟฟ้า",
    name_en: "Electrical",
    icon: "⚡",
    sort_order: 2,
    input_fields: [
      { key: "amp", label_th: "ขนาดมิเตอร์ (แอมป์)", label_en: "Meter Size (Amp)", type: "select" },
      { key: "point_count", label_th: "จำนวนจุด", label_en: "Number of Points", type: "number" },
      { key: "wire_type", label_th: "ประเภทสายไฟ", label_en: "Wire Type", type: "select" },
      { key: "distance", label_th: "ระยะทาง (เมตร)", label_en: "Distance (m)", type: "number" }
    ],
    presets: [
      { slug: "new", name_th: "ติดตั้งใหม่", name_en: "New Installation" },
      { slug: "repair", name_th: "ซ่อมแซม", name_en: "Repair" },
      { slug: "add", name_th: "เพิ่มจุด", name_en: "Add Points" }
    ]
  },
  {
    slug: "plumbing",
    name_th: "ช่างประปา",
    name_en: "Plumbing",
    icon: "🚿",
    sort_order: 3,
    input_fields: [
      { key: "pipe_type", label_th: "ประเภทท่อ", label_en: "Pipe Type", type: "select" },
      { key: "point_count", label_th: "จำนวนจุด", label_en: "Number of Points", type: "number" },
      { key: "distance", label_th: "ระยะทาง (เมตร)", label_en: "Distance (m)", type: "number" },
      { key: "floor_level", label_th: "ชั้น", label_en: "Floor Level", type: "number" }
    ],
    presets: [
      { slug: "new", name_th: "ติดตั้งใหม่", name_en: "New Installation" },
      { slug: "repair", name_th: "ซ่อมแซม", name_en: "Repair" },
      { slug: "modify", name_th: "ดัดแปลง", name_en: "Modify" }
    ]
  },
  {
    slug: "solar",
    name_th: "โซล่า",
    name_en: "Solar",
    icon: "☀️",
    sort_order: 4,
    input_fields: [
      { key: "kw", label_th: "กำลังการผลิต (kW)", label_en: "Capacity (kW)", type: "number" },
      { key: "inverter_type", label_th: "ประเภทอินเวอร์เตอร์", label_en: "Inverter Type", type: "select" },
      { key: "panel_count", label_th: "จำนวนแผง", label_en: "Number of Panels", type: "number" },
      { key: "roof_type", label_th: "ประเภทหลังคา", label_en: "Roof Type", type: "select" }
    ],
    presets: [
      { slug: "new", name_th: "ติดตั้งใหม่", name_en: "New Installation" },
      { slug: "upgrade", name_th: "เพิ่มกำลัง", name_en: "Capacity Upgrade" },
      { slug: "inspect", name_th: "ตรวจเช็ค", name_en: "Inspection" }
    ]
  },
  {
    slug: "cctv",
    name_th: "CCTV",
    name_en: "CCTV",
    icon: "📹",
    sort_order: 5,
    input_fields: [
      { key: "cameras", label_th: "จำนวนกล้อง", label_en: "Number of Cameras", type: "number" },
      { key: "resolution", label_th: "ความละเอียด", label_en: "Resolution", type: "select" },
      { key: "dvr_channel", label_th: "ช่อง DVR", label_en: "DVR Channels", type: "select" },
      { key: "cable_length", label_th: "ความยาวสาย (เมตร)", label_en: "Cable Length (m)", type: "number" }
    ],
    presets: [
      { slug: "new", name_th: "ติดตั้งใหม่", name_en: "New Installation" },
      { slug: "upgrade", name_th: "อัพเกรด", name_en: "Upgrade" },
      { slug: "add", name_th: "เพิ่มกล้อง", name_en: "Add Camera" }
    ]
  },
  {
    slug: "autodoor",
    name_th: "ประตูอัตโนมัติ",
    name_en: "Auto Door",
    icon: "🚪",
    sort_order: 6,
    input_fields: [
      { key: "door_type", label_th: "ประเภทประตู", label_en: "Door Type", type: "select" },
      { key: "width", label_th: "ความกว้าง (เมตร)", label_en: "Width (m)", type: "number" },
      { key: "height", label_th: "ความสูง (เมตร)", label_en: "Height (m)", type: "number" },
      { key: "motor_type", label_th: "ประเภทมอเตอร์", label_en: "Motor Type", type: "select" },
      { key: "control_type", label_th: "ประเภทควบคุม", label_en: "Control Type", type: "select" }
    ],
    presets: [
      { slug: "new", name_th: "ติดตั้งใหม่", name_en: "New Installation" },
      { slug: "repair", name_th: "ซ่อมแซม", name_en: "Repair" },
      { slug: "upgrade", name_th: "ปรับปรุง", name_en: "Upgrade" }
    ]
  }
]

calculator_services.each do |cs|
  CalculatorService.find_or_create_by!(slug: cs[:slug]) do |s|
    s.name_th = cs[:name_th]
    s.name_en = cs[:name_en]
    s.icon = cs[:icon]
    s.sort_order = cs[:sort_order]
    s.input_fields = cs[:input_fields]
    s.presets = cs[:presets]
    s.active = true
    puts "Created CalculatorService: #{cs[:name_th]}"
  end
end

puts "✅ Calculator Services seeded: #{CalculatorService.count}"
