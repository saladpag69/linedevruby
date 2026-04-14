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
    @service_type = ServiceType.find_by(slug: service_type_slug)
    @inputs = inputs.symbolize_keys
    @prices = {}
  end

  def calculate
    return { error: "Service type not found" } unless @service_type

    vals = calculate_base_values
    materials = calculate_materials(vals[:area], vals[:volume])
    labor = calculate_labor(vals[:area])

    {
      service_type: @service_type,
      inputs: @inputs,
      area: vals[:area],
      volume: vals[:volume],
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
        product_slug: mat[:slug],
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

    volume = case @service_type.slug
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
    return [] unless @service_type.materials.present?

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
