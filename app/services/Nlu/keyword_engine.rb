# app/services/nlu/keyword_engine.rb
module Nlu
  class KeywordEngine
    INTENT_RULES = {
      "ASK_PRICE" => %w[ราคาเท่าไหร่ ราคากี่บาท ราคาอะไร],
      "ASK_ORDER_STATUS" => %w[ได้หรือยัง ของถึงยัง ส่งหรือยัง มาหรือยัง],
      "ASK_PRODUCT_SPEC" => %w[สูงเท่าไหร่ ขนาดเท่าไหร่ กี่ซม กี่เซน กี่เซ็น],
      "ASK_SHIPPING_COST" => %w[ค่าส่ง ส่งฟรี กี่วงส่งฟรี ส่งกี่วง ส่งเท่าไหร่]
    }.freeze

    def self.call(text:)
      new(text).call
    end

    def initialize(text)
      @text = normalize(text)
    end

    def call
      intent, confidence = detect_intent

      {
        intent: intent || "UNKNOWN",
        confidence: confidence || 0.0,
        entities: {} # ส่วน entity ให้ NLP/LLM ช่วย
      }
    end

    private

    def normalize(text)
      text.to_s.downcase.gsub(/\s+/, "")
    end

    def detect_intent
      INTENT_RULES.each do |intent, keywords|
        keywords.each do |kw|
          return [intent, 0.9] if @text.include?(kw.gsub(/\s+/, ""))
        end
      end

      # ถ้าไม่แม่นมาก อาจมี rule หลวม ๆ ได้
      # เช่น มีคำว่า "ราคา" เฉย ๆ → ASK_PRICE แต่ให้ confidence ต่ำกว่านิด
      if @text.include?("ราคา")
        return ["ASK_PRICE", 0.6]
      end

      nil
    end
  end
end
