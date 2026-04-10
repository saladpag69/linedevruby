class SiamcosmoController < ApplicationController
  before_action :set_language, only: [ :index ]
  before_action :set_color_theme, only: [ :index ]
  before_action :store_return_to, only: [ :change_language ]

  def index
    @services = HomeContentService.services(@lang)
    @t = HomeContentService.translations(@lang)
    @products = ActiveProduct.all.first(12)
    @cart_count = session[:cart_id] ? Cart.find_by(id: session[:cart_id])&.cart_items&.sum(:quantity) || 0 : 0
  end

  def change_language
    session[:lang] = params[:lang] || "th"
    session[:color_theme] = params[:color] if params[:color].present?
    redirect_to session[:return_to] || root_path
  end

  private

  def set_language
    @lang = session[:lang] || "th"
  end

  def store_return_to
    session[:return_to] = request.referer || root_path
  end

  def set_color_theme
    @color_key = session[:color_theme] || params[:color] || "C"
    session[:color_theme] = @color_key
    @color = HomeContentService.color(@color_key)
  end
end
