class SupplierLinesController < ApplicationController
  def create
    SupplierLineNotifier.new(message: supplier_message).call
    render json: { message: "ส่งข้อความถึงทีมซัพพลายเออร์เรียบร้อยแล้ว" }, status: :ok
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
end
