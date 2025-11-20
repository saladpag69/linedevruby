# app/services/active_product_client.rb
require "net/http"
require "json"

class ActiveProductClient
  ENDPOINT = URI("http://baansiam25.ap-southeast-1.elasticbeanstalk.com/api/v1/product/load/activeproduct")

  def fetch_products
    response = Net::HTTP.get_response(ENDPOINT)
    raise "API error #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  end
end

