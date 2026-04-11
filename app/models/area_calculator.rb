class AreaCalculator
  attr_reader :shape, :length, :width, :height, :base, :parallel1, :parallel2, :radius

  def initialize(params)
    @shape = params[:shape]
    @length = params[:length].to_f
    @width = params[:width].to_f
    @height = params[:height].to_f
    @base = params[:base].to_f
    @parallel1 = params[:parallel1].to_f
    @parallel2 = params[:parallel2].to_f
    @radius = params[:radius].to_f
  end

  def calculate
    { area: area }
  end

  private

  def area
    case shape
    when "rectangle" then width * length
    when "triangle" then 0.5 * base * height
    when "trapezoid" then 0.5 * (parallel1 + parallel2) * height
    when "circle" then Math::PI * radius*2
    else 0
    end
  end
end
