require "openai"
class SupplierLinesController < ApplicationController
  def create
    # SupplierLineNotifier.new(message: supplier_message).call
    extracted    = MessageProductExtractor.new(supplier_message).call
    message = extracted[:response]

    products = if message.present?
                 ActiveProduct.none
               elsif extracted[:barcode].present?
                 ActiveProduct.where(barcodeid: extracted[:barcode])
               elsif extracted[:keyword].present?
                 ActiveProduct.search(extracted[:keyword])
               else
                 ActiveProduct.none
               end

               nlu_result = Nlu::Orchestrator.call(text: supplier_message, customer: "userid", products:nil)
    # parsed_result = parse_llm_result(nlu_result)
    # response_text = extract_llm_message(parsed_result) || nlu_result.to_s
              llm_message = nlu_result
              test_parsed = JSON.parse(llm_message) # แปลงเป็น hash
              test_response = test_parsed.dig("message")
              
              
    render json: { message: test_response }, status: :ok
  rescue StandardError => e
    Rails.logger.error("Failed to push supplier line message: #{e.message}")
    render json: { message: "ส่งข้อความไม่สำเร็จ โปรดลองอีกครั้ง" }, status: :internal_server_error
  end

  private

  def supplier_message
    override_message = params[:message].to_s.strip
    return override_message if override_message.present?

    query = params[:query].to_s.strip

    if query.present?
      "ผู้ใช้ขอความช่วยเหลือเกี่ยวกับสินค้า: \"#{query}\" จากหน้า Active Products"
    else
      "ผู้ใช้ขอให้ติดต่อกลับจากหน้า Active Products"
    end
  end

  def parse_llm_result(result)
    return result if result.is_a?(Hash)

    JSON.parse(result)
  rescue JSON::ParserError
    nil
  end

  def extract_llm_message(parsed_result)
    return if parsed_result.blank?

    message = parsed_result["message"] || parsed_result["reply"] || parsed_result["response"]
    return message if message.is_a?(String)

    if message.is_a?(Hash)
      message["_content"] || message["content"] || message["text"]
    end
  end
end
