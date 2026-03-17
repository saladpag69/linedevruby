# app/services/nlu/llm_engine.rb
module Nlu
  class LlmEngine
    def self.call(text:, products:)
      new(text, products).call
    end

    def initialize(text, products)
      @text = text
      @products = products
    end

    def llmSearchProduct
    end

    def call
      response = ask_llm(@text, @products)
      # content = response.choices.first.message[:content]
      # parsed = JSON.parse(content) # แปลงเป็น hash
      # product = parsed.dig("entities", "product")
      # Rails.logger.debug("🧟‍♀️🧟‍♀️🧟‍♀️🧟‍♀️🧟‍♀️"+response)
      # {
      #   intent: json["intent"] || "UNKNOWN",
      #   confidence: json["confidence"] || 0.8, # จะให้ fix 0.8 ไว้ก็ได้
      #   entities: (json["entities"] || {}).symbolize_keys,
      #   # message: json["message"] || "AI กำลังปรับปรุง"
      # }
      response


    rescue StandardError => e
      Rails.logger.error("LLM error: #{e.message}")
      { intent: "UNKNOWN", confidence: 0.0, entities: {} }
    end

    private

    def ask_llm(text, products)
        if products.blank?
          items = []
        else
          items = products.first(5).map do |p|
            { id: p._id, name: p.productname, price: p.productsale6, stock: p.productstock.present? }
          end
        end

      prompt = build_prompt(text, items)

      # Rails.application.credentials.OPENAI_API_KEY
      openai = OpenAI::Client.new(
        api_key: OPENAI_API_KEY
      )
      response = openai.chat.completions.create(
        model: :"gpt-4.1-mini",
        messages: [
          { role: "system", content: "ตอบเป็นข้อความ" },
          { role: "user", content: prompt }
        ]
      )
      content = response.choices.first.message[:content]
    end

    def build_prompt(text, items)
    <<~PROMPT
      คุณเป็นตัวช่วยที่เข้าใจข้อความจากลูกค้าเกี่ยวกับสินค้าในร้านวัสดุก่อสร้างระดับมืออาชีพ

      หน้าที่ของคุณคือ:
      - ตอบคำถามเกี่ยวกับสินค้า
      - แนะนำสินค้าที่เหมาะสม
      - เช็คราคา / ระบุสต็อกจากข้อมูลที่ให้
      - คำนวณจำนวนวัสดุก่อสร้าง
      - วิเคราะห์ภาพสินค้าเพื่อทายรุ่น/ขนาด
      - เสนอสินค้าที่ขายคู่กัน (Upsell)
      - ปิดการขายให้เร็วที่สุด
      - ตอบด้วยภาษาง่าย สุภาพ สไตล์พนักงานขายร้านวัสดุ

      ข้อมูลร้าน:
      ชื่อร้าน: บ้านสยามวัสดุ่ก่อสร้าง
      ที่อยู่: จ.พระนครศรีอยุธยา
      เวลาทำการ: 24 ชม.
      พื้นที่จัดส่งฟรี: 20 กม.
      เบอร์ติดต่อ: 094-161-4447

      ประเภทสินค้าที่ร้านขาย:
      - ปูนซีเมนต์ทุกชนิด
      - เหล็กเส้น เหล็กกล่อง
      - สีทาบ้าน สีงานเหล็ก
      - อุปกรณ์ประปา PVC
      - อุปกรณ์ไฟฟ้า
      - กระเบื้อง ปูพื้น/ผนัง
      - เครื่องมือช่าง
      - วัสดุก่อสร้างทั่วไป

      **กฎการตอบ**
      1. ถ้าลูกค้าถามหาสินค้า →  ข้อมูลสินค้าที่หาเจอ (สูงสุด 5 รายการ):
       #{items.to_json}
      2. ถ้าลูกค้าถามจากรูปภาพ → วิเคราะห์และบอกสินค้าที่น่าจะใช่ที่สุด
      3. ถ้าลูกค้าถาม “ต้องใช้อะไรดี?” → ให้ 2 ตัวเลือกและบอกข้อดี–ข้อเสีย
      4. ถ้าลูกค้าถามจำนวนวัสดุ → ให้คำนวณจากสูตรมาตรฐาน
      5. ตอบแบบสั้นกระชับ ไม่เวิ่นเว้อ
      6.

      **คำสั่งคำนวณจำนวนวัสดุ (สูตรพื้นฐาน)**
      - เทพื้น 1 ตร.ม. หนา 5 ซม. = ปูน 1.5–2 ถุง
      - ก่ออิฐมอญ 1 ตร.ม. = อิฐ 50–55 ก้อน
      - ฉาบผนัง 1 ตร.ม. = ปูนฉาบ 5–6 กก.
      - กระเบื้องพื้น/ผนัง = +10% เผื่อแตก/ตัด
      - ท่อ PVC ใช้มาตรฐานขนาดตามตาราง
      - เหล็กเส้นคิดตามหน้าเสา/คานที่ลูกค้าบอก

      **รูปแบบการปิดการขาย**
      ให้ถามเสมอว่า:
      - สอบถามเพิ่มเติมได้เลยค่ะ

      นำคำตอบไปใส่ใน _content

      วิเคราะห์ประโยคต่อไปนี้และตอบเป็น JSON เท่านั้น ห้ามมีข้อความอื่นนอกจาก JSON

        intent ต้องเป็นหนึ่งใน:
        - ASK_PRICE          (ถามราคา)
        - ASK_ORDER_STATUS   (ถามสถานะของที่สั่ง)
        - ASK_PRODUCT_SPEC   (ถามสเปค เช่น สูงเท่าไหร่)
        - ASK_SHIPPING_COST  (ถามค่าส่ง, เงื่อนไขส่งฟรี)
        - UNKNOWN            (ถ้าตัดสินใจไม่ได้)



         ตัวอย่าง JSON:
         {"intent":"ASK_PRICE","entities":{"product":"วงส้วม","size":80},"message":{_content}}

      ประโยค:
      "#{text}"
    PROMPT
      # <<~PROMPT
      #   คุณเป็นตัวช่วยเข้าใจข้อความจากลูกค้าเกี่ยวกับสินค้าในร้านวัสดุก่อสร้าง

      #   วิเคราะห์ประโยคต่อไปนี้และตอบเป็น JSON เท่านั้น ห้ามมีข้อความอื่นนอกจาก JSON

      #   intent ต้องเป็นหนึ่งใน:
      #   - ASK_PRICE          (ถามราคา)
      #   - ASK_ORDER_STATUS   (ถามสถานะของที่สั่ง)
      #   - ASK_PRODUCT_SPEC   (ถามสเปค เช่น สูงเท่าไหร่)
      #   - ASK_SHIPPING_COST  (ถามค่าส่ง, เงื่อนไขส่งฟรี)
      #   - UNKNOWN            (ถ้าตัดสินใจไม่ได้)

      #   entities ให้ใส่ได้ เช่น:
      #   - product: ชื่อสินค้า เช่น "วงส้วม"
      #   - size: ขนาดเช่น 80 (ตัวเลข)
      #   - quantity: จำนวนวง เช่น 40 (ตัวเลข)

      #   ตัวอย่าง JSON:
      #   {"intent":"ASK_PRICE","entities":{"product":"วงส้วม","size":80}}

      #   ประโยค:
      #   "#{text}"
      # PROMPT
    end
  end
end
