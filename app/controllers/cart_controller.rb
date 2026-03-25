class CartController < ApplicationController
  def show
    @carts = Cart.active.includes(:cart_items).order(created_at: :desc)
  end

  def add
    product = ActiveProduct.all.find { |p| p._id.to_s == params[:product_id] }
    if product
      CartService.add_item(web_user_id, product)
      flash[:notice] = "เพิ่ม #{product.productname} ลงตะกร้าแล้ว"
    else
      flash[:alert] = "ไม่พบสินค้า"
    end
    redirect_back(fallback_location: aboutus_path)
  end

  private

  def web_user_id
    session[:web_user_id] ||= "web_#{SecureRandom.hex(8)}"
  end
end
