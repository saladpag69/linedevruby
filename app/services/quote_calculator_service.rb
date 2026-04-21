class QuoteCalculatorService
  PRODUCT_MAPPING = {
    "cement_50kg" => [ "ปูน", "50 กก" ],
    "sand" => [ "ทราย" ],
    "gravel" => [ "หิน" ],
    "paint" => [ "สี" ],
    "paint_primer" => [ "สีรองพื้น" ],
    "tile_60x60" => [ "กระเบื้อง 60x60" ],
    "tile_30x30" => [ "กระเบื้อง 30x30" ],
    "cement_block" => [ "อิฐ" ],
    "rebar" => [ "เหล็ก" ]
  }.freeze

  def initialize(service_type_slug, inputs = {})
    @service_type_slug = service_type_slug
    @service_type = ServiceType.find_by(slug: service_type_slug) if service_type_slug.present?
    @calculator_service = CalculatorService.find_by(slug: service_type_slug)
    @inputs = inputs.symbolize_keys
    @prices = {}
  end

  def calculate
    if @calculator_service
      calculate_by_category
    elsif @service_type
      calculate_legacy
    else
      { error: "Service type not found" }
    end
  end

  def calculate_by_category
    case @calculator_service.slug
    when "construction"
      calculate_construction
    when "electrical"
      calculate_electrical
    when "plumbing"
      calculate_plumbing
    when "solar"
      calculate_solar
    when "cctv"
      calculate_cctv
    when "autodoor"
      calculate_autodoor
    else
      { error: "Unknown category: #{@calculator_service.slug}" }
    end
  end

  def calculate_construction
    width = @inputs[:width].to_f
    length = @inputs[:length].to_f
    thickness = @inputs[:thickness].to_f
    concrete_grade = @inputs[:concrete_grade].to_i

    area = width * length
    volume = area * thickness
    concrete_volume = volume

    concrete_price = case concrete_grade
    when 180 then 2800
    when 210 then 3200
    when 240 then 3600
    when 280 then 4000
    when 320 then 4500
    else 3600
    end

    concrete_total = concrete_volume * concrete_price
    mesh_total = area * 30
    labor_total = area * 400
    transport = volume >= 5 ? 1500 : 0

    material_total = concrete_total + mesh_total
    total = material_total + labor_total + transport
    price_per_sqm = area > 0 ? total / area : 0

    {
      category: "construction",
      inputs: @inputs,
      area: area,
      volume: volume,
      area_display: "%.2f ตร.ม." % area,
      volume_display: "%.2f ลบ.ม." % volume,
      materials: [
        { name: "คอนกรีต #{concrete_grade} KSC", quantity: concrete_volume.round(2), unit: "ลบ.ม.", price: concrete_price, subtotal: concrete_total },
        { name: "ไว์เมช", quantity: area.round(2), unit: "ตร.ม.", price: 30, subtotal: mesh_total }
      ],
      material_total: material_total,
      labor_total: labor_total,
      transport: transport,
      total: total,
      price_per_sqm: price_per_sqm,
      price_range: "฿#{(total * 0.9).round.to_i} - ฿#{(total * 1.1).round.to_i}"
    }
  end

  def calculate_electrical
    amp = @inputs[:amp].to_i
    point_count = @inputs[:point_count].to_i
    wire_type = @inputs[:wire_type] || "standard"
    distance = @inputs[:distance].to_f

    wire_price_per_m = wire_type == "pure" ? 45 : 25
    labor_per_point = 150
    box_price = 80
    breaker_price = case amp
    when 15 then 120
    when 30 then 180
    when 50 then 350
    else 200
    end

    wire_total = distance * wire_price_per_m
    box_total = box_price * ((point_count / 5.0).ceil)
    breaker_total = breaker_price
    material_total = wire_total + box_total + breaker_total
    labor_total = point_count * labor_per_point
    total = material_total + labor_total

    {
      category: "electrical",
      inputs: @inputs,
      materials: [
        { name: "สายไฟ #{wire_type == 'pure' ? 'ทองแดง' : 'มาตรฐาน'}", quantity: distance, unit: "ม.", price: wire_price_per_m, subtotal: wire_total },
        { name: "กล่องไฟ", quantity: (point_count / 5.0).ceil, unit: "ชิ้น", price: box_price, subtotal: box_total },
        { name: "เบรกเกอร์ #{amp}A", quantity: 1, unit: "ตัว", price: breaker_price, subtotal: breaker_total }
      ],
      material_total: material_total,
      labor_total: labor_total,
      transport: 0,
      total: total,
      price_per_sqm: point_count > 0 ? total / point_count : 0,
      price_range: "฿#{(total * 0.9).round.to_i} - ฿#{(total * 1.1).round.to_i}"
    }
  end

  def calculate_plumbing
    pipe_type = @inputs[:pipe_type] || "pvc"
    point_count = @inputs[:point_count].to_i
    distance = @inputs[:distance].to_f
    floor_level = @inputs[:floor_level].to_i

    pipe_price_per_m = case pipe_type
    when "pvc" then 45
    when "pp" then 120
    when "pe" then 80
    else 45
    end

    fitting_per_point = 5
    fitting_price = 15
    valve_price = 80
    labor_per_point = 200

    pipe_total = distance * pipe_price_per_m
    fitting_total = point_count * fitting_per_point * fitting_price
    valve_total = (point_count / 3.0).ceil * valve_price
    material_total = pipe_total + fitting_total + valve_total
    labor_total = point_count * labor_per_point + (floor_level * 50)
    total = material_total + labor_total

    {
      category: "plumbing",
      inputs: @inputs,
      materials: [
        { name: "ท่อ #{pipe_type.upcase}", quantity: distance, unit: "ม.", price: pipe_price_per_m, subtotal: pipe_total },
        { name: "ข้อต่อ", quantity: point_count * fitting_per_point, unit: "ชิ้น", price: fitting_price, subtotal: fitting_total },
        { name: "วาล์ว", quantity: (point_count / 3.0).ceil, unit: "ตัว", price: valve_price, subtotal: valve_total }
      ],
      material_total: material_total,
      labor_total: labor_total,
      transport: 0,
      total: total,
      price_per_sqm: point_count > 0 ? total / point_count : 0,
      price_range: "฿#{(total * 0.9).round.to_i} - ฿#{(total * 1.1).round.to_i}"
    }
  end

  def calculate_solar
    kw = @inputs[:kw].to_f
    inverter_type = @inputs[:inverter_type] || "on-grid"
    panel_count = @inputs[:panel_count].to_i
    roof_type = @inputs[:roof_type] || "tile"

    panel_price = 3500
    inverter_price = case inverter_type
    when "on-grid" then 15000
    when "off-grid" then 25000
    when "hybrid" then 35000
    else 15000
    end
    dc_cable_price = 800
    bracket_price = case roof_type
    when "metal" then 500
    when "concrete" then 800
    else 600
    end

    panel_total = panel_count * panel_price
    inverter_total = inverter_price
    dc_cable_total = dc_cable_price
    bracket_total = panel_count * bracket_price
    material_total = panel_total + inverter_total + dc_cable_total + bracket_total
    labor_total = kw * 3000
    total = material_total + labor_total

    {
      category: "solar",
      inputs: @inputs,
      materials: [
        { name: "แผงโซลาร์ #{panel_count} แผง", quantity: panel_count, unit: "แผง", price: panel_price, subtotal: panel_total },
        { name: "อินเวอร์เตอร์ #{inverter_type}", quantity: 1, unit: "ตัว", price: inverter_price, subtotal: inverter_total },
        { name: "สายไฟ DC", quantity: 1, unit: "ชุด", price: dc_cable_price, subtotal: dc_cable_total },
        { name: "ขายึดแผง", quantity: panel_count, unit: "ชุด", price: bracket_price, subtotal: bracket_total }
      ],
      material_total: material_total,
      labor_total: labor_total,
      transport: 0,
      total: total,
      price_per_sqm: kw > 0 ? total / kw : 0,
      price_range: "฿#{(total * 0.9).round.to_i} - ฿#{(total * 1.1).round.to_i}"
    }
  end

  def calculate_cctv
    cameras = @inputs[:cameras].to_i
    resolution = @inputs[:resolution] || "1080p"
    dvr_channel = @inputs[:dvr_channel].to_i
    cable_length = @inputs[:cable_length].to_f

    camera_price = case resolution
    when "1080p" then 1200
    when "2k" then 1800
    when "4k" then 2500
    else 1200
    end
    dvr_price = case dvr_channel
    when 4 then 2500
    when 8 then 4500
    when 16 then 8000
    else 2500
    end
    cable_price = 15
    hdd_price = 1500
    labor_per_camera = 500

    camera_total = cameras * camera_price
    dvr_total = dvr_price
    cable_total = cable_length * cable_price
    hdd_total = hdd_price
    material_total = camera_total + dvr_total + cable_total + hdd_total
    labor_total = cameras * labor_per_camera
    total = material_total + labor_total

    {
      category: "cctv",
      inputs: @inputs,
      materials: [
        { name: "กล้อง #{resolution}", quantity: cameras, unit: "ตัว", price: camera_price, subtotal: camera_total },
        { name: "DVR #{dvr_channel} ช่อง", quantity: 1, unit: "เครื่อง", price: dvr_price, subtotal: dvr_total },
        { name: "สาย", quantity: cable_length, unit: "ม.", price: cable_price, subtotal: cable_total },
        { name: "HDD", quantity: 1, unit: "ตัว", price: hdd_price, subtotal: hdd_total }
      ],
      material_total: material_total,
      labor_total: labor_total,
      transport: 0,
      total: total,
      price_per_sqm: cameras > 0 ? total / cameras : 0,
      price_range: "฿#{(total * 0.9).round.to_i} - ฿#{(total * 1.1).round.to_i}"
    }
  end

  def calculate_autodoor
    door_type = @inputs[:door_type] || "sliding"
    width = @inputs[:width].to_f
    height = @inputs[:height].to_f
    motor_type = @inputs[:motor_type] || "standard"
    control_type = @inputs[:control_type] || "remote"

    motor_price = case motor_type
    when "standard" then 8000
    when "heavy" then 15000
    else 8000
    end
    rail_price = width * 500
    remote_price = 500
    sensor_price = 800
    labor_total = 2000

    motor_total = motor_price
    rail_total = rail_price
    remote_total = remote_price
    sensor_total = sensor_price
    material_total = motor_total + rail_total + remote_total + sensor_total
    total = material_total + labor_total

    {
      category: "autodoor",
      inputs: @inputs,
      materials: [
        { name: "มอเตอร์ #{motor_type}", quantity: 1, unit: "ตัว", price: motor_price, subtotal: motor_total },
        { name: "ราง", quantity: width, unit: "ม.", price: 500, subtotal: rail_total },
        { name: "รีโมท", quantity: 2, unit: "ตัว", price: 250, subtotal: remote_total },
        { name: "เซ็นเซอร์", quantity: 1, unit: "ชุด", price: sensor_price, subtotal: sensor_total }
      ],
      material_total: material_total,
      labor_total: labor_total,
      transport: 0,
      total: total,
      price_per_sqm: (width * height) > 0 ? total / (width * height) : 0,
      price_range: "฿#{(total * 0.9).round.to_i} - ฿#{(total * 1.1).round.to_i}"
    }
  end

  def calculate_legacy
    vals = calculate_base_values
    materials = calculate_materials(vals[:area], vals[:volume])
    labor = calculate_labor(vals[:area])

    {
      service_type: @service_type,
      service_type_slug: @service_type.slug,
      inputs: @inputs,
      area: vals[:area],
      volume: vals[:volume],
      area_display: "%.2f ตร.ม." % vals[:area],
      volume_display: "%.2f ลบ.ม." % vals[:volume],
      materials: materials,
      material_total: materials.sum { |m| m[:subtotal] },
      labor_rate: @service_type.labor_rate_per_sqm,
      labor_total: labor,
      formula_preview: build_formula_preview(vals)
    }
  end

  def calculate_and_build_quote(user: nil, contractor: nil, delivery_option: "pickup")
    result = calculate
    return result if result[:error]

    delivery_fee = delivery_option == "delivery" ? Quote::DEFAULT_DELIVERY_FEE : 0
    material_total = result[:material_total]
    labor_total = result[:labor_total]
    tax = (material_total + labor_total) * Quote::TAX_RATE
    grand_total = material_total + labor_total + delivery_fee + tax

    quote = Quote.new(
      service_type: @service_type,
      contractor: contractor,
      user: user,
      inputs: @inputs,
      area: result[:area],
      volume: result[:volume],
      material_total: material_total,
      labor_total: labor_total,
      delivery_fee: delivery_fee,
      delivery_option: delivery_option,
      status: "draft"
    )

    result[:materials].each do |mat|
      quote.quote_materials.build(
        product_slug: mat[:slug] || mat[:name],
        product_name: mat[:name],
        quantity: mat[:quantity],
        unit: mat[:unit],
        unit_price: mat[:price],
        subtotal: mat[:subtotal]
      )
    end

    quote.save!
    quote
  end

  def self.find_price_by_slug(slug, prices_data)
    keywords = PRODUCT_MAPPING[slug] || [ slug ]
    prices_data.each do |p|
      name = p["productname"] || p[:productname] || ""
      return p["productsale1"].to_f if keywords.any? { |k| name.include?(k) }
    end
    nil
  end

  private

  def calculate_base_values
    width = @inputs[:width].to_f
    length = @inputs[:length].to_f
    height = @inputs[:height].to_f
    thickness = @inputs[:thickness].to_f
    depth = @inputs[:depth].to_f

    area = width * length

    volume = case @service_type&.slug
    when "concrete_floor"
      area * thickness
    when "brick_wall"
      area * thickness
    when "paint_wall"
      area
    when "tile_floor"
      area
    when "plumbing"
      height
    else
      area * [ thickness, depth, height ].compact.max.to_f
    end

    { area: area, volume: volume }
  end

  def calculate_materials(area, volume)
    return [] unless @service_type&.materials.present?

    @service_type.materials.map do |mat|
      slug = mat["product_slug"]
      qty_formula = mat["qty_formula"]
      unit = mat["unit"] || "ชิ้น"

      qty = eval_formula(qty_formula, { area: area, volume: volume }).ceil
      price = find_price(slug)
      subtotal = qty * price

      {
        slug: slug,
        name: find_product_name(slug),
        quantity: qty,
        unit: unit,
        price: price,
        subtotal: subtotal
      }
    end
  end

  def calculate_labor(area)
    area * @service_type.labor_rate_per_sqm.to_f
  end

  def eval_formula(formula, vars)
    return 0 if formula.blank?

    expr = formula.dup
    vars.each do |key, value|
      expr.gsub!(/\b#{key}\b/, value.to_s)
    end

    begin
      eval(expr).to_f
    rescue StandardError
      0
    end
  end

  def find_price(slug)
    @prices[slug] ||= begin
      prices = window_prices
      self.class.find_price_by_slug(slug, prices) || fallback_price(slug)
    end
  end

  def find_product_name(slug)
    return "ปูนซีเมนต์ 50 กก." if slug == "cement_50kg"
    return "ทรายหยาบ" if slug == "sand"
    return "หิน 3/4" if slug == "gravel"
    return "สี TOA 4 Season" if slug == "paint"
    return "สีรองพื้น TOA" if slug == "paint_primer"
    return "กระเบื้อง 60x60" if slug == "tile_60x60"
    return "กระเบื้อง 30x30" if slug == "tile_30x30"
    return "อิฐมวลเบา" if slug == "cement_block"
    return "เหล็กเส้น 12 มม." if slug == "rebar"
    slug.humanize
  end

  def window_prices
    @prices_data ||= Rails.cache.read("baansiam_prices") || []
  end

  def fallback_price(slug)
    fallback = {
      "cement_50kg" => 188,
      "sand" => 660,
      "gravel" => 730,
      "paint" => 1505,
      "paint_primer" => 380,
      "tile_60x60" => 85,
      "tile_30x30" => 45,
      "cement_block" => 8,
      "rebar" => 85
    }
    fallback[slug] || 100
  end

  def build_formula_preview(vals)
    type = @service_type.name_th
    area_str = "#{vals[:area].round(2)} ตร.ม."
    vol_str = "#{vals[:volume].round(2)} ลบ.ม."
    "#{type} · พื้นที่ #{area_str} · ปริมาตร #{vol_str}"
  end
end
