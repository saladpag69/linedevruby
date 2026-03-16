# frozen_string_literal: true

class MessageProductExtractor
  STOP_WORDS = %w[
    ครับ ค่ะ จ้า นะ ครับผม ค่ะหน่อย หน่อย ราคา เท่าไร บอกที ช่วยที เอ่อ นิดนึง ถุง ใบ ลัง กล่อง
  ].freeze
  GREETING_WORDS = %w[
    สวัสดี หวัดดี hello hi hey ยินดี ทัก สวัสดีครับ สวัสดีค่ะ ดีจ้า
  ].freeze
  REQUEST_WORDS = %w[
    ขอ ขอหน่อย ช่วย ช่วยหา หา หาให้ อยาก อยากได้ ต้องการ สั่ง ส่งให้
  ].freeze

  TALK_WITH_BOT_WORDS = %w[
    คุยกับบอท คุยกับ คุย คุยกับ คุยกับบอท
  ].freeze

  SCHEDULE_WORDS = %w[
    กำหนด กำหนดเวลา กำหนดวัน กำหนดเวลาให้ กำหนดวันให้ จองคิว
  ].freeze

  CHECK_SCHEDULE_WORDS = %w[
    ตามสินค้า ตรวจสอบ ตรวจสอบเวลา ตรวจสอบวัน ตรวจสอบเวลาให้ ตรวจสอบวันให้ ตรวจสอบคิว
  ].freeze

  OPEN_WEBSITE_WORDS = %w[
    เปิดเว็บไซต์ เปิดเว็บ เปิดเว็บไซต์ให้ เปิดเว็บให้ เปิดหน้าเว็บ
  ].freeze

  CHECK_PRICE_WORDS = %w[
    ราคาสินค้า ราคาของสินค้า ราคาสินค้าให้ ราคาของสินค้าให้
  ].freeze

  STOCK_WORDS = %w[
    มีไหม เหลือกี่ สต็อก เหลือไหม คงเหลือ มีป่วย
  ].freeze

  CART_WORDS = %w[
    ดูตะกร้า เช็คตะกร้า ตะกร้าฉัน
  ].freeze

  CLEAR_CART_WORDS = %w[
    ล้างตะกร้า ล้างตะกร้า ลบตะกร้า ลบรายการ ยกเลิก
  ].freeze

  WORD_FILTER = (STOP_WORDS + GREETING_WORDS + REQUEST_WORDS + STOCK_WORDS).uniq.freeze
  RESPONSE_TEXT = {
    greeting: "สวัสดีครับ 👋 บอกชื่อสินค้าที่ต้องการได้เลยนะครับ",
    talk_with_bot: "คุยกับบอทได้เลยครับ",
    request: "ช่วยพิมพ์ชื่อสินค้าให้หน่อยครับ จะได้ค้นหาให้ถูกต้อง",
    schedule: "แอดมินกำลังตรวจสอบคิวจัดส่งให้ครับ ",
    check_schedule: "กรุณาพิมพ์หมายเลขบิลส่งสินค้า",
    open_website: "คุณสามารถเปิดเว็บไซต์ได้เลยครับ",
    check_price: "กรุณาพิมพ์ชื่อสินค้าที่ต้องการตรวจสอบราคา",
    stock: "บอกชื่อสินค้าที่ต้องการทราบสต็อกได้เลยครับ"
  }.freeze
  BARCODE_REGEX = /\A\d{8,13}\z/

  def initialize(text)
    @text = text.to_s
  end



  def call
    response_key = detect_response(@text)

    if response_key && ![ :stock, :check_price, :view_cart, :clear_cart ].include?(response_key)
      return { response: RESPONSE_TEXT.fetch(response_key), intent: response_key }
    end

    cleaned, unit = extract_unit(@text)
    cleaned = normalize_text(cleaned)  # filter stock words from keyword
    return { barcode: cleaned } if barcode?(cleaned)

    result = { keyword: cleaned }
    result[:intent] = response_key if response_key
    result[:unit] = unit if unit
    result
  end

  private

  def extract_unit(text)
    units = %w[ถุง ใบ ลัง กล่อง หน่วย ก้อน เส้น ตัว เครื่อง อัน ชิ้น กระป๋อง ถัง ขวด แกลลอน]
    lowered = text.downcase

    found_unit = units.find { |u| lowered.include?(u) }
    return [ text, nil ] unless found_unit

    cleaned = text.gsub(found_unit, "").squeeze(" ").strip
    [ cleaned, found_unit ]
  end

  def normalize_text(text)
    lowered = text.downcase

    filtered = WORD_FILTER.reduce(lowered) do |result, word|
      result.gsub(word, " ")
    end

    filtered.gsub(/[^[:alnum:]\s]/, " ").squeeze(" ").strip
  end

  def detect_response(text)
    lowered = text.to_s.downcase
    return :greeting if word_in_list?(lowered, GREETING_WORDS)
    return :request if word_in_list?(lowered, REQUEST_WORDS)
    return :talk_with_bot if word_in_list?(lowered, TALK_WITH_BOT_WORDS)
    return :schedule if word_in_list?(lowered, SCHEDULE_WORDS)
    return :check_schedule if word_in_list?(lowered, CHECK_SCHEDULE_WORDS)
    return :open_website if word_in_list?(lowered, OPEN_WEBSITE_WORDS)
    return :check_price if word_in_list?(lowered, CHECK_PRICE_WORDS)
    return :stock if word_in_list?(lowered, STOCK_WORDS)
    return :view_cart if word_in_list?(lowered, CART_WORDS)
    return :clear_cart if word_in_list?(lowered, CLEAR_CART_WORDS)

    nil
  end

  def word_in_list?(text, list)
    list.any? { |word| text.include?(word.downcase) }
  end

  def barcode?(text)
    BARCODE_REGEX.match?(text)
  end
end
