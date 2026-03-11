# app/services/nlu/orchestrator.rb
require 'openai'

module Nlu
  class Orchestrator
    def self.call(text:, customer: nil,products: nil)
      new(text, customer,products).call
    end

    def initialize(text, customer, products)
      @text = text.to_s.strip
      @customer = customer
      @products = products

    end

    def call
      # 1) keyword + nlp
      kw_result  = KeywordEngine.call(text: @text)



      nlp_result = NlpEngine.call(text: @text)


      merged = merge_keyword_and_nlp(kw_result, nlp_result)
      # Rails.logger.debug("🏆🏆🏆🏆🏆🏆 kw_result + nlp_result :#{merged}")

      # 2) ตัดสินใจว่าจะเรียก LLM ไหม
      # if need_llm?(merged)
      #   llm_result = LlmEngine.call(text: @text)
      #   merged = merge_with_llm(merged, llm_result)
      # end
      #



      llm_result = LlmEngine.call(text: @text, products: @products)
      # Rails.logger.debug("🏆🏆🏆🏆🏆🏆 llm_result :#{llm_result}")

      parsed_llm = parse_llm_result(llm_result)
      return llm_result if parsed_llm.nil?

      JSON.generate(merge_with_llm(merged, parsed_llm))
    end

    private

    def need_llm?(result)
      result[:intent] == "UNKNOWN" || result[:confidence].to_f < 0.6
    end

    def merge_keyword_and_nlp(kw, nlp)
      {
        intent: kw[:intent] || "UNKNOWN",
        confidence: kw[:confidence] || 0.0,
        entities: (kw[:entities] || {}).merge(nlp[:entities] || {})
      }
    end

    def merge_with_llm(base, llm)
      llm_intent = fetch_llm_value(llm, :intent)
      llm_confidence = fetch_llm_value(llm, :confidence)
      llm_entities = fetch_llm_value(llm, :entities)
      llm_message = fetch_llm_value(llm, :message)

      if llm_entities.is_a?(Hash)
        llm_entities = llm_entities.transform_keys { |key| key.to_sym rescue key }
      else
        llm_entities = {}
      end

      # ให้ LLM override เฉพาะที่มั่นใจ เช่น intent หรือ entity บางตัว
      merged = {
        intent: llm_intent || base[:intent],
        confidence: llm_confidence || base[:confidence],
        entities: base[:entities].merge(llm_entities)
      }

      merged[:message] = llm_message if llm_message.present?
      merged
    end

    def parse_llm_result(result)
      return result if result.is_a?(Hash)

      JSON.parse(result.to_s)
    rescue JSON::ParserError
      nil
    end

    def fetch_llm_value(llm, key)
      return if llm.nil?
      llm[key] || llm[key.to_s] || llm[key.to_sym]
    end
  end
end
