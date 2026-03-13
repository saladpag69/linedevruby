# app/services/nlu/keyword_engine.rb
module Nlu
  class KeywordEngine
    INTENT_RULES = {
      "ASK_PRICE" => %w[ราคาเท่าไหร่ ราคากี่บาท ราคาอะไร],
      "ASK_STOCK" => %w[สต็อก มีไหม เหลือไหม คงเหลือ],
      "ORDER" => %w[สั่ง ขอซื้อ ต้องการ],
      "QUOTATION" => %w[ใบเสนอราคา quotation quote]
    }.freeze

    def self.call(text:)
      new(text).call
    end

    def initialize(text)
      @text = text.to_s.strip
    end

    def call
      intent, confidence = detect_intent(@text)

      {
        intent: intent || "UNKNOWN",
        confidence: confidence || 0.0,
        entities: {}
      }
    end

    private

    def detect_intent(text)
      normalized = text.downcase

      case normalized
      when /ราคา|เท่าไร|กี่บาท/
        [ "ASK_PRICE", 0.9 ]
      when /สต็อก|มีไหม|เหลือ|คงเหลือ/
        [ "ASK_STOCK", 0.9 ]
      when /สั่ง|ขอซื้อ|ต้องการ/
        [ "ORDER", 0.9 ]
      when /ใบเสนอราคา|quotation|quote/
        [ "QUOTATION", 0.9 ]
      else
        nil
      end
    end
  end
end
