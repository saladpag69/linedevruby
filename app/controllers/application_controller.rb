class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  def index
  end
  def about
    @query = params[:q].to_s.strip
    @products = ActiveProduct.search(@query)
  rescue => e
    Rails.logger.error("Active product API failed: #{e.message}")
    @products = []
    @query = ""
  end

  stale_when_importmap_changes
end
