require "minitest/autorun"
require_relative "../../app/services/construction_formulas"

class ConstructionFormulasTest < Minitest::Test
  def test_calculate_concrete_floor_returns_correct_number_of_items
    result = ConstructionFormulas.calculate_concrete_floor(width: 10, length: 10, thickness: 0.10, concrete_grade: 240)
    assert_equal 4, result.size
  end

  def test_calculate_concrete_floor_calculates_correct_concrete_volume
    result = ConstructionFormulas.calculate_concrete_floor(width: 10, length: 10, thickness: 0.10, concrete_grade: 240)
    concrete = result.find { |m| m[:name].include?("คอนกรีตผสมเสร็จ") }
    assert_in_delta 10.0, concrete[:quantity]
    assert_equal "ลบ.ม.", concrete[:unit]
    assert_equal 1850, concrete[:price]
    assert_in_delta 18500, concrete[:subtotal]
  end

  def test_calculate_concrete_floor_calculates_mesh_area_with_5_percent_waste
    result = ConstructionFormulas.calculate_concrete_floor(width: 10, length: 10, thickness: 0.10, concrete_grade: 240)
    mesh = result.find { |m| m[:name].include?("ไวร์เมช") }
    assert_in_delta 105.0, mesh[:quantity]
    assert_equal "ตร.ม.", mesh[:unit]
  end

  def test_calculate_metal_roof_calculates_correct_area
    result = ConstructionFormulas.calculate_metal_roof(roof_width: 10, rafter_length: 5)
    assert_equal 5, result.size
  end

  def test_calculate_metal_roof_calculates_screws_per_square_meter
    result = ConstructionFormulas.calculate_metal_roof(roof_width: 10, rafter_length: 5)
    screws = result.find { |m| m[:name].include?("สกรู") }
    assert_equal 239, screws[:quantity]
  end

  def test_calculate_gypsum_ceiling_returns_8_items
    result = ConstructionFormulas.calculate_gypsum_ceiling(area: 50, perimeter: 30)
    assert_equal 8, result.size
  end

  def test_calculate_gypsum_ceiling_calculates_correct_sheet_count
    result = ConstructionFormulas.calculate_gypsum_ceiling(area: 50, perimeter: 30)
    sheets = result.find { |m| m[:name].include?("ยิปซัม") }
    assert_equal 20, sheets[:quantity]
  end

  def test_calculate_tbar_ceiling_returns_7_items
    result = ConstructionFormulas.calculate_tbar_ceiling(area: 50, perimeter: 30)
    assert_equal 7, result.size
  end

  def test_calculate_lightweight_wall_calculates_studs_correctly
    result = ConstructionFormulas.calculate_lightweight_wall(wall_area: 30, wall_height: 3)
    assert_equal 7, result.size
    studs = result.find { |m| m[:name].include?("C-Stud") }
    assert_equal 18, studs[:quantity]
  end

  def test_calculate_lightweight_wall_supports_smartboard
    result = ConstructionFormulas.calculate_lightweight_wall(wall_area: 30, wall_height: 3, board_type: "smartboard")
    board = result.find { |m| m[:name].include?("สมาร์ทบอร์ด") }
    refute_nil board
    assert_equal 280, board[:price]
  end

  def test_calculate_tile_returns_5_items
    result = ConstructionFormulas.calculate_tile(area: 50, tile_w: 60, tile_l: 60)
    assert_equal 5, result.size
  end

  def test_calculate_tile_calculates_correct_tile_quantity_with_10_percent_waste
    result = ConstructionFormulas.calculate_tile(area: 50, tile_w: 60, tile_l: 60)
    tiles = result.find { |m| m[:name].include?("กระเบื้อง") }
    assert_equal 153, tiles[:quantity]
  end

  def test_calculate_tile_wall_has_different_labor_price
    floor_result = ConstructionFormulas.calculate_tile(area: 50, surface: "floor")
    wall_result = ConstructionFormulas.calculate_tile(area: 50, surface: "wall")
    floor_labor = floor_result.find { |m| m[:name].include?("ค่าแรง") }
    wall_labor = wall_result.find { |m| m[:name].include?("ค่าแรง") }
    assert_equal 180, floor_labor[:price]
    assert_equal 220, wall_labor[:price]
  end

  def test_calculate_aac_wall_returns_5_items
    result = ConstructionFormulas.calculate_aac_wall(wall_area: 50, block_thick: 10)
    assert_equal 5, result.size
  end

  def test_calculate_aac_wall_calculates_correct_block_quantity
    result = ConstructionFormulas.calculate_aac_wall(wall_area: 50, block_thick: 10)
    blocks = result.find { |m| m[:name].include?("อิฐมวลเบา") }
    assert_equal 438, blocks[:quantity]
  end

  def test_calculate_aac_wall_calculates_plaster_bags_for_2_sides
    result = ConstructionFormulas.calculate_aac_wall(wall_area: 50)
    plaster = result.find { |m| m[:name].include?("ปูนฉาบ") }
    assert_equal 30, plaster[:quantity]
  end

  def test_calculate_paint_returns_4_items
    result = ConstructionFormulas.calculate_paint(area: 100, coats: 2, surface: "interior")
    assert_equal 4, result.size
  end

  def test_calculate_paint_exterior_has_higher_price
    interior_result = ConstructionFormulas.calculate_paint(area: 100, surface: "interior")
    exterior_result = ConstructionFormulas.calculate_paint(area: 100, surface: "exterior")
    interior_topcoat = interior_result.find { |m| m[:name].include?("สีทาบ้าน") }
    exterior_topcoat = exterior_result.find { |m| m[:name].include?("สีทาบ้าน") }
    assert_equal 1650, interior_topcoat[:price]
    assert_equal 1850, exterior_topcoat[:price]
  end

  def test_calculate_slab_rebar_returns_2_items
    result = ConstructionFormulas.calculate_slab_rebar(area: 100, main_bar_mm: 12, spacing: 0.20)
    assert_equal 2, result.size
  end

  def test_calculate_slab_rebar_calculates_correct_weight
    result = ConstructionFormulas.calculate_slab_rebar(area: 100, main_bar_mm: 12, spacing: 0.20)
    rebar = result.find { |m| m[:name].include?("เหล็ก DB12") }
    assert_in_delta 976.8, rebar[:quantity], 1.0
  end

  def test_calculate_plumbing_returns_7_items
    result = ConstructionFormulas.calculate_plumbing(bathrooms: 2, kitchens: 1)
    assert_equal 7, result.size
  end

  def test_calculate_plumbing_calculates_fixtures_correctly
    result = ConstructionFormulas.calculate_plumbing(bathrooms: 2, kitchens: 1)
    toilet = result.find { |m| m[:name].include?("โถส้วม") }
    assert_equal 2, toilet[:quantity]
  end

  def test_calculate_plumbing_calculates_pipe_length_correctly
    result = ConstructionFormulas.calculate_plumbing(bathrooms: 2, kitchens: 1)
    pipe_2inch = result.find { |m| m[:name].include?('2"') }
    pipe_half = result.find { |m| m[:name].include?('1/2"') }
    assert_equal 18, pipe_2inch[:quantity]
    assert_equal 30, pipe_half[:quantity]
  end

  def test_calculate_openings_handles_doors
    doors = [{ type: "aluminum_slide", w: 1.2, h: 2.1, qty: 2 }]
    result = ConstructionFormulas.calculate_openings(doors: doors, windows: [])
    assert_equal 2, result.size
    assert result.any? { |m| m[:name].include?("ประตู") }
    assert result.any? { |m| m[:name].include?("วงกบ") }
  end

  def test_calculate_openings_handles_windows
    windows = [{ type: "aluminum_slide", width: 1.0, height: 1.2, qty: 3 }]
    result = ConstructionFormulas.calculate_openings(doors: [], windows: windows)
    assert_equal 1, result.size
    window = result.first
    assert_equal 3, window[:quantity]
  end

  def test_calculate_total_sums_materials_correctly
    materials = [
      { name: "วัสดุ A", quantity: 10, unit: "ชิ้น", price: 100, subtotal: 1000 },
      { name: "ค่าแรง", quantity: 10, unit: "ตร.ม.", price: 50, subtotal: 500 }
    ]
    result = ConstructionFormulas.calculate_total(materials)
    assert_equal 1500, result[:total]
    assert_equal 500, result[:labor_total]
    assert_equal 1000, result[:material_only_total]
  end
end