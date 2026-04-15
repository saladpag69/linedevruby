class SiamcosmoController < ApplicationController
  before_action :set_locale
  layout "siamcosmo"

  def index
    begin
      @services = Service.active.order(:id)
    rescue StandardError => e
      Rails.logger.error "Failed to load services: #{e.message}"
      @services = []
    end
  end

  alias_method :home, :index
  alias_method :landing, :index

  def show
    @service = Service.find_by(key: params[:id])
    redirect_to root_path unless @service
  end

  def set_language
    locale = params[:locale]&.to_sym
    if locale && I18n.available_locales.include?(locale)
      session[:locale] = locale
      I18n.locale = locale
    else
      session[:locale] ||= I18n.default_locale
    end
    redirect_back fallback_location: root_path
  end

  private

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end
end
