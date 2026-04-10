class CalculatorService
  class << self
    def calculate_area(shape, params)
      case shape
      when "rectangle"
        calculate_rectangle(params)
      when "triangle"
        calculate_triangle(params)
      when "trapezoid"
        calculate_trapezoid(params)
      when "circle"
        calculate_circle(params)
      else
        { error: "รูปแบบไม่รู้จัก" }
      end
    end

    def calculate_wall_area(params)
      walls = params[:walls] || []
      total_area = 0
      wall_details = []

      walls.each do |wall|
        width = wall[:width].to_f
        height = wall[:height].to_f
        wall_area = width * height

        door_width = wall[:door_width].to_f
        door_height = wall[:door_height].to_f
        door_count = wall[:door_count].to_i
        door_area = door_width * door_height * door_count

        paintable_area = wall_area - door_area
        total_area += paintable_area
        wall_details << {
          width: width,
          height: height,
          wall_area: wall_area,
          door_area: door_area,
          paintable_area: paintable_area
        }
      end

      {
        total_area: total_area,
        walls: wall_details,
        unit: "ตร.ม."
      }
    end

    def calculate_volume(params)
      length = params[:length].to_f
      width = params[:width].to_f
      height = params[:height].to_f
      volume = length * width * height

      ratio = params[:ratio] || "1:2:4"
      materials = calculate_materials(volume, ratio)

      {
        volume: volume,
        materials: materials,
        unit: "ลบ.ม."
      }
    end

    private

    def calculate_rectangle(params)
      width = params[:width].to_f
      height = params[:height].to_f
      area = width * height

      {
        shape: "สี่เหลี่ยม",
        inputs: {
          width: width,
          height: height,
          width_label: "กว้าง",
          height_label: "ยาว"
        },
        area: area,
        unit: "ตร.ม."
      }
    end

    def calculate_triangle(params)
      base = params[:base].to_f
      height = params[:height].to_f
      area = 0.5 * base * height

      {
        shape: "สามเหลี่ยม",
        inputs: {
          base: base,
          height: height,
          base_label: "ฐาน",
          height_label: "สูง"
        },
        area: area,
        unit: "ตร.ม."
      }
    end

    def calculate_trapezoid(params)
      parallel1 = params[:parallel1].to_f
      parallel2 = params[:parallel2].to_f
      height = params[:height].to_f
      area = 0.5 * (parallel1 + parallel2) * height

      {
        shape: "สี่เหลี่ยมคางหมู",
        inputs: {
          parallel1: parallel1,
          parallel2: parallel2,
          height: height,
          parallel1_label: "ด้านคู่ขนาน 1",
          parallel2_label: "ด้านคู่ขนาน 2",
          height_label: "สูง"
        },
        area: area,
        unit: "ตร.ม."
      }
    end

    def calculate_circle(params)
      radius = params[:radius].to_f
      area = Math::PI * radius * radius

      {
        shape: "วงกลม",
        inputs: {
          radius: radius,
          radius_label: "รัศมี"
        },
        area: area,
        unit: "ตร.ม."
      }
    end

    def calculate_materials(volume, ratio)
      case ratio
      when "1:2:4"
        cement_bags = (volume * 7).round(2)
        sand = (volume * 0.44).round(2)
        gravel = (volume * 0.88).round(2)
      when "1:3:6"
        cement_bags = (volume * 4.5).round(2)
        sand = (volume * 0.45).round(2)
        gravel = (volume * 0.9).round(2)
      when "1:1.5:3"
        cement_bags = (volume * 10).round(2)
        sand = (volume * 0.42).round(2)
        gravel = (volume * 0.84).round(2)
      else
        cement_bags = 0
        sand = 0
        gravel = 0
      end

      {
        cement_bags: cement_bags,
        cement_unit: "ถุง (50 กก.)",
        sand: sand,
        sand_unit: "ลบ.ม.",
        gravel: gravel,
        gravel_unit: "ลบ.ม.",
        ratio: ratio
      }
    end
  end
end
