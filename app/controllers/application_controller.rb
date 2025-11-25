# app/controllers/application_controller.rb
require "net/http"
require "uri"
require "json"
require "securerandom"

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  def index
  end
  def login
  end
  def about
    @query = params[:q].to_s.strip
    trigger_supply_push if params[:supply_push].present?
    trigger_test_push if params[:test_push].present?
    @products = ActiveProduct.search(@query)
  rescue => e
    Rails.logger.error("Active product API failed: #{e.message}")
    @products = []
    @query = ""
  end

  stale_when_importmap_changes

  private

  def trigger_supply_push
    LinePushJob.perform_later(LINE_CHANNEL_ID, "sayhi")
  rescue StandardError => e
    Rails.logger.error("trigger_supply_push failed: #{e.message}")
  end

  def trigger_test_push
    LinePushJob.perform_later(
      "C825174a05b34cfec346b837944651495",
      [
        { type: "text", text: "Hello, world1" },
        { type: "text", text: "Hello, world2" }
      ]
    )
  rescue StandardError => e
    Rails.logger.error("trigger_test_push failed: #{e.message}")
  end
end
