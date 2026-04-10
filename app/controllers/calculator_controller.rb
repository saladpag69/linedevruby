class CalculatorController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :calculate_area, :calculate_wall, :calculate_volume ]
  before_action :set_language
  before_action :set_color_theme

  def index
    @t = HomeContentService.translations(@lang)
    @services = HomeContentService.services(@lang)
    @shapes = [ "rectangle", "triangle", "trapezoid", "circle" ]
    @ratios = [ "1:2:4", "1:3:6", "1:1.5:3" ]
  end

  def calculate_area
    shape = params[:area][:shape]
    result = CalculatorService.calculate_area(shape, area_params)
    render json: result
  end

  def calculate_wall
    result = CalculatorService.calculate_wall_area(wall_params)
    render json: result
  end

  def calculate_volume
    result = CalculatorService.calculate_volume(volume_params)
    render json: result
  end

  private

  def set_language
    @lang = session[:lang] || "th"
  end

  def set_color_theme
    @color_key = session[:color_theme] || "C"
    @color = HomeContentService.color(@color_key)
  end

  def area_params
    params.require(:area).permit(:shape, :width, :height, :base, :parallel1, :parallel2, :radius)
  end

  def wall_params
    params.permit(walls: [ :width, :height, :door_width, :door_height, :door_count ])
  end

  def volume_params
    params.permit(:length, :width, :height, :ratio)
  end
end
