# SiamCosmo Services Seed
services = [
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
      { th: "เปรียบเทีย���ค่าบริการ", en: "Compare Rates", zh: "比较费用" },
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

services.each do |s|
  Service.find_or_create_by!(key: s[:key]) do |service|
    service.name_th = s[:name_th]
    service.name_en = s[:name_en]
    service.name_zh = s[:name_zh]
    service.icon = s[:icon]
    service.greeting_message = s[:greeting_message_th]
    service.suggestions = s[:suggestions]
    service.is_active = true
    puts "Created: #{s[:name_th]}"
  end
end

puts "✅ Services seeded: #{Service.count}"
