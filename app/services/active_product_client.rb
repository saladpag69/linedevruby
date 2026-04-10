# app/services/active_product_client.rb
require "net/http"
require "json"

class ActiveProductClient
  ENDPOINT = URI("https://backendbaansiam2025-production.up.railway.app/api/v1/product/load/activeproduct")
  CACHE_KEY = "active_products_v1"
  CACHE_EXPIRY = 10.minutes

  def fetch_products
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY) do
      http = Net::HTTP.new(ENDPOINT.host, ENDPOINT.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      headers = {}
      if ENV["PRODUCT_API_KEY"].present?
        headers["X-API-Key"] = ENV["PRODUCT_API_KEY"]
      end
      response = http.get(ENDPOINT.path, headers)

      raise "API error #{response.code}" unless response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    end
  end

  def self.refresh_cache
    Rails.cache.delete(CACHE_KEY)
    new.fetch_products
  end
end
