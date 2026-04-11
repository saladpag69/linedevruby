class Api::PricesController < ApplicationController
  BAANSIAM_API_URL = "https://backendbaansiam2025-production.up.railway.app/api/v1/product/load/activeproduct"
  CACHE_DURATION = 1.hour

  def index
    cached_prices = Rails.cache.read("baansiam_prices")

    if cached_prices.present?
      render json: cached_prices
      return
    end

    begin
      response = HTTParty.get(BAANSIAM_API_URL, timeout: 10)
      if response.success?
        products = response.parsed_response
        Rails.cache.write("baansiam_prices", products, expires_in: CACHE_DURATION)
        render json: products
      else
        render json: { error: "Failed to fetch prices", fallback: fallback_prices }, status: :service_unavailable
      end
    rescue StandardError => e
      Rails.logger.error("Baansiam API error: #{e.message}")
      render json: { error: "Service unavailable", fallback: fallback_prices }, status: :service_unavailable
    end
  end

  private

  def fallback_prices
    [
      { "productname" => "ปูนเสือ เขียว 50 กก", "productsale1" => 188, "productunit" => "ถุง" },
      { "productname" => "ทรายหยาบ พร้อมส่ง(ครึ่งกระบะ)", "productsale1" => 660, "productunit" => "ครึ่งกระบะ" },
      { "productname" => "หิน 3/4 พร้อมส่ง(ครึ่งคันกระบะ)", "productsale1" => 730, "productunit" => "ครึ่งคัน" },
      { "productname" => "สี TOA 4SESON กึ่งเงา ขนาด 2.5 GL", "productsale1" => 1505, "productunit" => "แกลลอน" },
      { "productname" => "กาวหมาแดง X-66 200 ml", "productsale1" => 78, "productunit" => "ขวด" },
      { "productname" => "ไม้อัดดำ 15 มิล ขอบแดง ใส้ต่อ", "productsale1" => 482, "productunit" => "แผ่น" },
      { "productname" => "กระเบื้อง 60x60 ซีเมนต์", "productsale1" => 85, "productunit" => "แผ่น" },
      { "productname" => "สีรองพื้น TOA 1 GL", "productsale1" => 380, "productunit" => "แกลลอน" }
    ]
  end
end
