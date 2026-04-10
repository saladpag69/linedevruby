class HomeContentService
  COLORS = {
    "A" => { bg: "#F8F9FA", bg_card: "#FFFFFF", primary: "#1E3A5F", secondary: "#D4AF37", accent: "#2C5282", text: "#1A202C", text_secondary: "#718096", name: "Navy Gold" },
    "B" => { bg: "#F0F4F8", bg_card: "#FFFFFF", primary: "#334E68", secondary: "#1DD3B0", accent: "#0891B2", text: "#1A202C", text_secondary: "#64748B", name: "Slate Teal" },
    "C" => { bg: "#F1F5F9", bg_card: "#FFFFFF", primary: "#1E3A8A", secondary: "#3B82F6", accent: "#60A5FA", text: "#1E293B", text_secondary: "#64748B", name: "Steel Blue" },
    "D" => { bg: "#F5F5F4", bg_card: "#FFFFFF", primary: "#292524", secondary: "#EA580C", accent: "#F97316", text: "#1C1917", text_secondary: "#78716C", name: "Charcoal Orange" }
  }.freeze

  def self.services(lang)
    lang ||= "th"
    case lang.to_sym
    when :th
      {
        calculator: { title: "เครื่องคำนวณวัสดุ", icon: "🧮", subtitle: "คำนวณราคาวัสดุก่อสร้าง", path: "/calculator" },
        documents: { title: "เอกสาร", icon: "📄", subtitle: "สัญญา ข้อตกลง", path: "/documents" },
        price: { title: "ราคาวัสดุ", icon: "💰", subtitle: "ราคาวัสดุอยุธยา", path: "/price" },
        contractor: { title: "ผู้รับเหมา", icon: "👷", subtitle: "ติดต่อผู้รับเหมา", path: "/contractor" },
        projects: { title: "ผลงาน", icon: "🏗️", subtitle: "ผลงานที่ผ่านมา", path: "/projects" },
        rental: { title: "เช่าเครื่องมือ", icon: "🔧", subtitle: "เช่าอุปกรณ์ก่อสร้าง", path: "/rental" },
        it: { title: "ไอที", icon: "💻", subtitle: "บริการด้านไอที", path: "/it" }
      }
    when :en
      {
        calculator: { title: "Material Calculator", icon: "🧮", subtitle: "Calculate construction material costs", path: "/calculator" },
        documents: { title: "Documents", icon: "📄", subtitle: "Contracts & Agreements", path: "/documents" },
        price: { title: "Material Price", icon: "💰", subtitle: "Ayutthaya material prices", path: "/price" },
        contractor: { title: "Contractor", icon: "👷", subtitle: "Contact contractors", path: "/contractor" },
        projects: { title: "Projects", icon: "🏗️", subtitle: "Past projects", path: "/projects" },
        rental: { title: "Equipment Rental", icon: "🔧", subtitle: "Rent construction equipment", path: "/rental" },
        it: { title: "IT Services", icon: "💻", subtitle: "Technology solutions", path: "/it" }
      }
    else
      services(:th)
    end
  end

  def self.translations(lang)
    lang ||= "th"
    case lang.to_sym
    when :th
      {
        "tagline" => "บริการครบจบในที่เดียว เพื่อชุมชนอยุธยา",
        "home" => "หน้าแรก",
        "services" => "บริการ",
        "calculator" => "เครื่องคำนวณวัสดุ",
        "documents" => "เอกสาร",
        "price" => "ราคาวัสดุ",
        "contractor" => "ผู้รับเหมา",
        "projects" => "ผลงาน",
        "rental" => "เช่าเครื่องมือ",
        "it" => "ไอที",
        "contact" => "ติดต่อ",
        "login" => "เข้าสู่ระบบ",
        "logout" => "ออกจากระบบ",
        "copyright" => "© 2025 SIAMCOSMO สงวนลิขสิทธิ์"
      }
    when :en
      {
        "tagline" => "All-in-one service for Ayutthaya community",
        "home" => "Home",
        "services" => "Services",
        "calculator" => "Material Calculator",
        "documents" => "Documents",
        "price" => "Material Price",
        "contractor" => "Contractor",
        "projects" => "Projects",
        "rental" => "Equipment Rental",
        "it" => "IT Services",
        "contact" => "Contact",
        "login" => "Login",
        "logout" => "Logout",
        "copyright" => "© 2025 SIAMCOSMO All Rights Reserved"
      }
    else
      translations(:th)
    end
  end

  def self.color(color_key)
    COLORS[color_key.to_s] || COLORS["A"]
  end
end
