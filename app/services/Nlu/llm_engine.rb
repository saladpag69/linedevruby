# app/services/nlu/llm_engine.rb
module Nlu
  class LlmEngine
    def self.call(text:)
      new(text).call
    end

    def initialize(text)
      @text = text
    end

    def call
      response = ask_llm(@text)
      # content = response.choices.first.message[:content]
      # parsed = JSON.parse(content) # แปลงเป็น hash
      # product = parsed.dig("entities", "product")
      Rails.logger.debug("🧟‍♀️🧟‍♀️🧟‍♀️🧟‍♀️🧟‍♀️"+response)
      # {
      #   intent: json["intent"] || "UNKNOWN",
      #   confidence: json["confidence"] || 0.8, # จะให้ fix 0.8 ไว้ก็ได้
      #   entities: (json["entities"] || {}).symbolize_keys,
      #   # message: json["message"] || "AI กำลังปรับปรุง"
      # }
      response
    
    rescue error => e
      Rails.logger.error("LLM error: #{e.message}")
      { intent: "UNKNOWN", confidence: 0.0, entities: {} }
    end

    private

    def ask_llm(text)
      prompt = build_prompt(text)
      
      openai = OpenAI::Client.new(
        api_key: "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"
      )
      response = openai.chat.completions.create(
        model: :"gpt-4.1-mini",
        messages: [
          { role: "system", content: "ตอบเป็นข้อความ" },
          { role: "user", content: prompt }
        ]
      )
      content = response.choices.first.message[:content]
      
      content
    end

    def build_prompt(text)
    <<~PROMPT
      คุณเป็นตัวช่วยเข้าใจข้อความจากลูกค้าเกี่ยวกับสินค้าในร้านวัสดุก่อสร้าง
      วิเคราะห์ประโยคต่อไปนี้และตอบเป็น JSON เท่านั้น ห้ามมีข้อความอื่นนอกจาก JSON

        intent ต้องเป็นหนึ่งใน:
        - ASK_PRICE          (ถามราคา)
        - ASK_ORDER_STATUS   (ถามสถานะของที่สั่ง)
        - ASK_PRODUCT_SPEC   (ถามสเปค เช่น สูงเท่าไหร่)
        - ASK_SHIPPING_COST  (ถามค่าส่ง, เงื่อนไขส่งฟรี)
        - UNKNOWN            (ถ้าตัดสินใจไม่ได้)

        _content = ตอบสั้นๆไม่เกิน 180 ตัวอักษร  
      ตัวอย่าง 
      #   ตัวอย่าง JSON:
      #   ถ้า intent เป็น UNKNOWN _content = อธิบายสั้นๆ แต่ถ้าไม่เข้าใจ ให้ตอบ "ไม่เข้าใจ"
      #   {"intent":"ASK_PRICE","entities":{"product":"วงส้วม","size":80},"message":{_content}}

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
