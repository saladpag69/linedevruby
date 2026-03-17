 class CartService
  EXPIRE_HOURS = 24

  def self.add_item(line_user_id, product)
    cart = get_or_create_cart(line_user_id)

    existing_item = cart.cart_items.find_by(sku: product.barcodeid)

    if existing_item
      existing_item.increment!(:quantity)
      existing_item
    else
      cart.cart_items.create!(
        product_name: product.productname,
        sku: product.barcodeid,
        price: product.productsale1,
        quantity: 1,
        unit: product.productunit
      )
    end
  end

  def self.get_cart(line_user_id)
    cart = Cart.active.find_by(line_user_id: line_user_id)
    return nil unless cart

    if cart.expired?
      cart.cart_items.destroy_all
      cart.destroy
      nil
    else
      cart
    end
  end

  def self.get_or_create_cart(line_user_id)
    cart = Cart.active.find_by(line_user_id: line_user_id)

    unless cart
      cart = Cart.create!(
        line_user_id: line_user_id,
        expires_at: EXPIRE_HOURS.hours.from_now
      )
    end

    cart
  end

  def self.clear_cart(line_user_id)
    cart = Cart.active.find_by(line_user_id: line_user_id)
    return unless cart

    cart.cart_items.destroy_all
    cart.destroy
  end

  def self.total_price(line_user_id)
    cart = get_cart(line_user_id)
    return 0 unless cart

    cart.cart_items.sum { |item| item.price.to_f * item.quantity }
  end

  def self.cart_summary(line_user_id)
    cart = get_cart(line_user_id)
    return nil unless cart

    {
      cart: cart,
      items: cart.cart_items,
      total: cart.cart_items.sum { |item| item.price.to_f * item.quantity },
      item_count: cart.cart_items.sum(&:quantity)
    }
  end
 end
