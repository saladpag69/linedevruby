class ConstructionFormulas
  REBAR_WEIGHT = {
    6 => 0.222,
    9 => 0.499,
    12 => 0.888,
    16 => 1.578,
    20 => 2.466,
    25 => 3.853
  }.freeze

  def self.calculate_concrete_floor(width:, length:, thickness: 0.10, concrete_grade: 240)
    area = width * length
    concrete_volume = (area * thickness * 1.00).round(2)
    mesh_area = (area * 1.00).round(2)
    sand_volume = (area * 0.05).round(2)
    sand_half_truck = (sand_volume / 0.4).ceil

    concrete_price = case concrete_grade
    when 180 then 1900
    when 210 then 2000
    when 240 then 2300
    when 280 then 2500
    when 320 then 2700
    else 2200
    end
    mesh_price = 45
    sand_price = 350

    [
      {
        name: "คอนกรีตผสมเสร็จ #{concrete_grade} KSC",
        quantity: concrete_volume,
        unit: "ลบ.ม.",
        price: concrete_price,
        subtotal: concrete_volume * concrete_price
      },
      {
        name: "ไวร์เมช 6\"x6\" MW50",
        quantity: mesh_area,
        unit: "ตร.ม.",
        price: mesh_price,
        subtotal: mesh_area * mesh_price
      },
      {
        name: "ทรายหยาบ รองพื้น 5 ซม.",
        quantity: sand_half_truck,
        unit: "ครึ่งกระบะ",
        price: sand_price,
        subtotal: sand_half_truck * sand_price
      },
      {
        name: "ค่าแรงเทพื้น (รวมเหล็ก)",
        quantity: area.round(2),
        unit: "ตร.ม.",
        price: 180,
        subtotal: area * 180
      }
    ]
  end

  def self.calculate_metal_roof(roof_width:, rafter_length:, overhang: 0.30, sheet_type: "0.47")
    effective_width = 0.76
    sheet_length = (rafter_length + overhang).round(2)
    sheets_per_row = (roof_width / effective_width).ceil
    total_area = (roof_width * sheet_length).round(2)
    screws = (total_area * 4.5).ceil
    foam_seal = sheets_per_row

    sheet_price = sheet_type == "0.35" ? 130 : 155
    screw_price = 3.5

    [
      {
        name: "แผ่นเมทัลชีท หนา #{sheet_type}มม. ยาว #{sheet_length}ม.",
        quantity: sheets_per_row,
        unit: "แผ่น",
        price: sheet_price * effective_width * sheet_length,
        subtotal: sheets_per_row * sheet_price * effective_width * sheet_length
      },
      {
        name: "สกรูยึดเมทัลชีท",
        quantity: screws,
        unit: "ตัว",
        price: screw_price,
        subtotal: screws * screw_price
      },
      {
        name: "โฟมปิดชายคา",
        quantity: foam_seal,
        unit: "ชิ้น",
        price: 25,
        subtotal: foam_seal * 25
      },
      {
        name: "แผ่นครอบสัน / ครอบจั่ว",
        quantity: (roof_width * 1.1).ceil,
        unit: "ม.",
        price: 120,
        subtotal: (roof_width * 1.1).ceil * 120
      },
      {
        name: "ค่าแรงมุงหลังคาเมทัลชีท",
        quantity: total_area,
        unit: "ตร.ม.",
        price: 80,
        subtotal: total_area * 80
      }
    ]
  end

  def self.calculate_gypsum_ceiling(area:, perimeter:)
    gypsum_sheets = (area * 0.37 * 1.08).ceil
    main_runner = (area * 0.92).ceil
    wall_angle = (perimeter / 3.0).ceil
    hanger_set = (area * 0.87).ceil
    clip_lock = (area * 2.63).ceil
    screws = (area * 14.7).ceil
    putty_bags = (area / 17.5).ceil

    [
      { name: "แผ่นยิปซัม 1.2x2.4 ม.", quantity: gypsum_sheets, unit: "แผ่น", price: 185, subtotal: gypsum_sheets * 185 },
      { name: "โครงซีลายน์ (Main Runner) 4ม.", quantity: main_runner, unit: "เส้น", price: 75, subtotal: main_runner * 75 },
      { name: "ฉากริม Wall Angle 3ม.", quantity: wall_angle, unit: "เส้น", price: 45, subtotal: wall_angle * 45 },
      { name: "ชุดแขวน (ลวด+สปริง+ขอล็อค)", quantity: hanger_set, unit: "ชุด", price: 25, subtotal: hanger_set * 25 },
      { name: "คลิปล็อค", quantity: clip_lock, unit: "ตัว", price: 4, subtotal: clip_lock * 4 },
      { name: "สกรูยิงฝ้า", quantity: screws, unit: "ตัว", price: 0.8, subtotal: screws * 0.8 },
      { name: "ปูนฉาบยิปซัม (ถุง 20กก.)", quantity: putty_bags, unit: "ถุง", price: 320, subtotal: putty_bags * 320 },
      { name: "ค่าแรงฝ้าซีลายน์", quantity: area, unit: "ตร.ม.", price: 220, subtotal: area * 220 }
    ]
  end

  def self.calculate_tbar_ceiling(area:, perimeter:)
    tbar_tiles = (area / 0.36 * 1.05).ceil
    main_tee = (area * 0.83).ceil
    cross_tee_120 = (area * 1.67).ceil
    cross_tee_60 = (area * 1.67).ceil
    wall_angle = (perimeter / 3.0).ceil
    hanger_set = (area * 1.25).ceil

    [
      { name: "แผ่นฝ้า T-Bar 60x60 ซม.", quantity: tbar_tiles, unit: "แผ่น", price: 65, subtotal: tbar_tiles * 65 },
      { name: "โครงหลัก Main Tee 3.6ม.", quantity: main_tee, unit: "เส้น", price: 85, subtotal: main_tee * 85 },
      { name: "โครงซอย Cross Tee 1.2ม.", quantity: cross_tee_120, unit: "เส้น", price: 32, subtotal: cross_tee_120 * 32 },
      { name: "โครงซอยเล็ก Cross Tee 0.6ม.", quantity: cross_tee_60, unit: "เส้น", price: 22, subtotal: cross_tee_60 * 22 },
      { name: "ฉากริม Wall Angle 3ม.", quantity: wall_angle, unit: "เส้น", price: 45, subtotal: wall_angle * 45 },
      { name: "ชุดแขวน (ลวด+สปริง)", quantity: hanger_set, unit: "ชุด", price: 22, subtotal: hanger_set * 22 },
      { name: "ค่าแรงฝ้า T-Bar", quantity: area, unit: "ตร.ม.", price: 150, subtotal: area * 150 }
    ]
  end

  def self.calculate_lightweight_wall(wall_area:, wall_height:, stud_spacing: 0.60, board_type: "gypsum")
    linear_m = (wall_area / wall_height).round(2)
    u_track = (linear_m * 2 * 1.05 / 3.0).ceil
    c_stud_qty = (linear_m / stud_spacing).ceil + 1
    board_area = wall_area * 2
    board_sheets = (board_area / 2.88 * 1.08).ceil
    concrete_anchor = (linear_m * 6).ceil
    drill_screws = (board_sheets * 30).ceil
    board_price = board_type == "smartboard" ? 280 : 185

    [
      { name: "โครงตัว U (U-Track) 3ม.", quantity: u_track, unit: "เส้น", price: 55, subtotal: u_track * 55 },
      { name: "โครงตัว C (C-Stud) 3ม.", quantity: c_stud_qty, unit: "เส้น", price: 65, subtotal: c_stud_qty * 65 },
      { name: "แผ่น#{board_type == "smartboard" ? "สมาร์ทบอร์ด" : "ยิปซัม"} 1.2x2.4ม.", quantity: board_sheets, unit: "แผ่น", price: board_price, subtotal: board_sheets * board_price },
      { name: "พุกคอนกรีต+สกรู", quantity: concrete_anchor, unit: "ตัว", price: 4, subtotal: concrete_anchor * 4 },
      { name: "สกรูปลายสว่าน ยึดโครง-แผ่น", quantity: drill_screws, unit: "ตัว", price: 0.9, subtotal: drill_screws * 0.9 },
      { name: "ยาแนว+เทปยิปซัม", quantity: (linear_m * wall_height / 10).ceil, unit: "ชุด", price: 180, subtotal: (linear_m * wall_height / 10).ceil * 180 },
      { name: "ค่าแรงผนังเบา", quantity: wall_area, unit: "ตร.ม.", price: 280, subtotal: wall_area * 280 }
    ]
  end

  def self.calculate_tile(area:, tile_w: 60, tile_l: 60, joint_width: 3, surface: "floor")
    tile_area_m2 = (tile_w / 100.0) * (tile_l / 100.0)
    tiles_qty = (area / tile_area_m2 * 1.10).ceil
    adhesive_bags = (area / 5.0).ceil
    grout_kg = (area * ((tile_w + tile_l) / 2.0) * joint_width * 1.7 / (tile_w * tile_l)).round(1)
    grout_bags = (grout_kg / 5.0).ceil

    tile_price = surface == "floor" ? 320 : 280
    labor_price = surface == "floor" ? 180 : 220

    [
      { name: "กระเบื้อง #{tile_w}x#{tile_l} ซม.", quantity: tiles_qty, unit: "แผ่น", price: tile_price * tile_area_m2, subtotal: tiles_qty * tile_price * tile_area_m2 },
      { name: "ปูนกาวซีเมนต์ (ถุง 20กก.)", quantity: adhesive_bags, unit: "ถุง", price: 195, subtotal: adhesive_bags * 195 },
      { name: "ยาแนวกระเบื้อง (ถุง 5กก.)", quantity: grout_bags, unit: "ถุง", price: 145, subtotal: grout_bags * 145 },
      { name: "น้ำยากันซึม (รองพื้นก่อนปู)", quantity: (area / 10.0).ceil, unit: "แกลลอน", price: 280, subtotal: (area / 10.0).ceil * 280 },
      { name: "ค่าแรงปูกระเบื้อง", quantity: area, unit: "ตร.ม.", price: labor_price, subtotal: area * labor_price }
    ]
  end

  def self.calculate_aac_wall(wall_area:, block_thick: 10)
    block_face_area = 0.20 * 0.60
    blocks_qty = (wall_area / block_face_area * 1.05).ceil
    mortar_bags = (wall_area * 0.015 / 0.04).ceil
    plaster_bags = (wall_area * 2 * 0.012 / 0.04).ceil

    [
      { name: "อิฐมวลเบา #{block_thick}x20x60 ซม.", quantity: blocks_qty, unit: "ก้อน", price: block_thick <= 10 ? 22 : 28, subtotal: blocks_qty * (block_thick <= 10 ? 22 : 28) },
      { name: "ปูนก่ออิฐมวลเบา (ถุง 25กก.)", quantity: mortar_bags, unit: "ถุง", price: 185, subtotal: mortar_bags * 185 },
      { name: "ปูนฉาบ AAC (ถุง 25กก.)", quantity: plaster_bags, unit: "ถุง", price: 175, subtotal: plaster_bags * 175 },
      { name: "ตาข่ายไฟเบอร์กลาสกันร้าว", quantity: (wall_area * 2 * 1.05).round(2), unit: "ตร.ม.", price: 12, subtotal: wall_area * 2 * 1.05 * 12 },
      { name: "ค่าแรงก่อ+ฉาบอิฐมวลเบา", quantity: wall_area, unit: "ตร.ม.", price: 320, subtotal: wall_area * 320 }
    ]
  end

  def self.calculate_paint(area:, coats: 2, surface: "interior", condition: "normal")
    
    base_coverage = case condition
    when "new" then 13.0
    when "old" then 9.0
    when "rough" then 7.5
    else 10.0
    end
  
    primer_coverage = base_coverage
    topcoat_coverage = surface == "exterior" ? 10.0 : 11.0
  
    primer_lt = (area / primer_coverage)
    topcoat_lt = (area * coats / topcoat_coverage)
  
    primer_gal5 = (primer_lt / 18.9).ceil
    topcoat_gal5 = (topcoat_lt / 18.9).ceil
  
    putty_kg = (area * 0.3).ceil
  
    topcoat_price = surface == "exterior" ? 1850 : 1650
  
    [
      { name: "รองพื้นปูนเก่า (Sealer Primer)", quantity: primer_gal5, unit: "ถัง 5 แกล.", price: 950, subtotal: primer_gal5 * 950 },
      { name: "สีทาบ้าน#{surface == "exterior" ? "ภายนอก" : "ภายใน"} (#{coats} รอบ)", quantity: topcoat_gal5, unit: "ถัง 5 แกล.", price: topcoat_price, subtotal: topcoat_gal5 * topcoat_price },
      { name: "ปูนขาวแต่งผิว/ปิดรอยร้าว", quantity: putty_kg, unit: "กก.", price: 25, subtotal: putty_kg * 25 },
      { name: "ค่าแรงทาสี", quantity: area, unit: "ตร.ม.", price: surface == "exterior" ? 45 : 35, subtotal: area * (surface == "exterior" ? 45 : 35) }
    ]
  end

  def self.calculate_slab_rebar(area:, main_bar_mm: 12, spacing: 0.20)
    bars_per_row = (1.0 / spacing).round(1)
    total_length = area * bars_per_row * 2 * 1.10
    total_kg = (total_length * (REBAR_WEIGHT[main_bar_mm] || 0.00617 * main_bar_mm**2)).round(1)

    [
      { name: "เหล็ก DB#{main_bar_mm} ระยะ #{(spacing * 100).to_i} ซม. (พื้น 2 ทิศ)", quantity: total_kg, unit: "กก.", price: 28, subtotal: total_kg * 28 },
      { name: "ลวดผูกเหล็ก", quantity: (total_kg / 100).ceil, unit: "กก.", price: 42, subtotal: (total_kg / 100).ceil * 42 }
    ]
  end

  def self.calculate_openings(doors: [], windows: [])
    items = []

    doors.each do |d|
      type_price = case d[:type]
      when "flush_hollow" then 1800
      when "flush_solid" then 3200
      when "pvc" then 2400
      when "aluminum_swing" then 4500
      when "aluminum_slide" then 5500
      else 2500
      end

      items << {
        name: "ประตู #{d[:w]}x#{d[:h]}ม. (#{d[:type]})",
        quantity: d[:qty] || 1,
        unit: "ชุด",
        price: type_price,
        subtotal: (d[:qty] || 1) * type_price
      }
      items << {
        name: "วงกบ+บานพับ+มือจับ",
        quantity: d[:qty] || 1,
        unit: "ชุด",
        price: 650,
        subtotal: (d[:qty] || 1) * 650
      }
    end

    windows.each do |w|
      type_price = case w[:type]
      when "aluminum_fixed" then 1200
      when "aluminum_slide" then 2800
      when "aluminum_awning" then 3200
      when "upvc_slide" then 4500
      else 2000
      end

      items << {
        name: "หน้าต่าง #{w[:width]}x#{w[:height]}ม. (#{w[:type]})",
        quantity: w[:qty] || 1,
        unit: "ชุด",
        price: type_price,
        subtotal: (w[:qty] || 1) * type_price
      }
    end

    items
  end

  def self.calculate_plumbing(bathrooms: 1, kitchens: 1, fixtures: {})
    default_fix = {
      toilet: bathrooms,
      shower: bathrooms,
      washbasin: bathrooms,
      kitchen_sink: kitchens
    }.merge(fixtures)

    pipe_pvc_2inch = (bathrooms + kitchens) * 6
    pipe_pvc_half = (bathrooms * 4 + kitchens * 2) * 3

    [
      { name: "โถส้วมนั่งราบ (รวมติดตั้ง)", quantity: default_fix[:toilet] || 0, unit: "ชุด", price: 3500, subtotal: (default_fix[:toilet] || 0) * 3500 },
      { name: "ฝักบัว (รวมก๊อกผสม)", quantity: default_fix[:shower] || 0, unit: "ชุด", price: 1800, subtotal: (default_fix[:shower] || 0) * 1800 },
      { name: "อ่างล้างหน้า (รวมก๊อก)", quantity: default_fix[:washbasin] || 0, unit: "ชุด", price: 2200, subtotal: (default_fix[:washbasin] || 0) * 2200 },
      { name: "อ่างล้างจาน 2 หลุม (รวมก๊อก)", quantity: default_fix[:kitchen_sink] || 0, unit: "ชุด", price: 3800, subtotal: (default_fix[:kitchen_sink] || 0) * 3800 },
      { name: "ท่อ PVC 2\" (น้ำทิ้ง)", quantity: pipe_pvc_2inch, unit: "เมตร", price: 85, subtotal: pipe_pvc_2inch * 85 },
      { name: "ท่อ PVC 1/2\" (น้ำดี)", quantity: pipe_pvc_half, unit: "เมตร", price: 22, subtotal: pipe_pvc_half * 22 },
      { name: "ค่าแรงช่างประปา", quantity: bathrooms + kitchens, unit: "จุด", price: 2500, subtotal: (bathrooms + kitchens) * 2500 }
    ]
  end

  def self.calculate_total(materials)
    material_total = materials.sum { |m| m[:subtotal] || 0 }
    labor_total = materials.filter { |m| m[:name]&.include?("ค่าแรง") }.sum { |m| m[:subtotal] || 0 }
    material_only_total = material_total - labor_total

    {
      materials: materials,
      material_total: material_total,
      labor_total: labor_total,
      material_only_total: material_only_total,
      total: material_total
    }
  end
end
