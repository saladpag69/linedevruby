# app/services/active_product_client.rb
require "net/http"
require "json"

class ActiveProductClient
  ENDPOINT = URI("https://backendbaansiam2025-production.up.railway.app/api/v1/product/load/activeproduct")

  def fetch_products
    http = Net::HTTP.new(ENDPOINT.host, ENDPOINT.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.get(ENDPOINT.path)
    raise "API error #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  end
end
