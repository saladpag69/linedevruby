class CartItem < ApplicationRecord
  belongs_to :cart

  def subtotal
    price.to_f * quantity
  end
end
