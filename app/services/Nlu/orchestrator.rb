# app/services/nlu/orchestrator.rb
require 'openai'

module Nlu
  class Orchestrator
    def self.call(text:, customer: nil,products: nil)
      new(text, customer,products).call
    end

    def initialize(text, customer,products)
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
      
      llm_result = LlmEngine.call(text: @text,products: @products)
      # Rails.logger.debug("🏆🏆🏆🏆🏆🏆 llm_result :#{llm_result}")      
      # merged = merge_with_llm(merged, llm_result)
      # Rails.logger.debug("🏆🏆🏆🏆🏆🏆 llm_result :#{merged}")      
      llm_result # => { intent: "...", confidence: 0.92, entities: {...} }
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
      # ให้ LLM override เฉพาะที่มั่นใจ เช่น intent หรือ entity บางตัว
      {
        intent: llm[:intent] || base[:intent],
        confidence: llm[:confidence] || base[:confidence],
        entities: base[:entities].merge(llm[:entities] || {})
        # message: base[:message].merge(llm[:message]||{})
        
        
      }
    end
  end
end
