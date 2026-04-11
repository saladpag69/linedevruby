class WallCalculator
  attr_reader :walls

  def initialize(params)
    @walls = params[:walls] || []
  end

  def calculate
    wall_areas = walls.map do |wall|
      wall_area = wall[:width].to_f * wall[:height].to_f
      door_area = wall[:door_width].to_f * wall[:door_height].to_f * wall[:door_count].to_i
      { paintable_area: wall_area - door_area }
    end

    {
      total_area: wall_areas.sum { |w| w[:paintable_area] },
      walls: wall_areas
    }
  end
end
