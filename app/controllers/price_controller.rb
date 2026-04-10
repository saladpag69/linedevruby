class PriceController < ApplicationController
  before_action :set_language
  before_action :set_color_theme

  def index
    @t = HomeContentService.translations(@lang)
    @services = HomeContentService.services(@lang)
    @service = @services[:price]
    @products = ActiveProduct.all
  end

  private

  def set_language
    @lang = session[:lang] || "th"
  end

  def set_color_theme
    @color_key = session[:color_theme] || "C"
    @color = HomeContentService.color(@color_key)
  end
end
