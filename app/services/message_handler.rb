# app/services/message_handler.rb
class MessageHandler
  
  
  def initialize(text)
    @text = text.to_s.strip
  end

  def call
    
    
    return :help if @text.blank?
    return :latest if @text.match?(/ล่าสุด|new/i)
    return { barcode: $1 } if @text.match?(/barcode[: ]?(\d+)/i)

    { keyword: @text }
  end
  
  private
  
  def clean_text(text)
    STOP_WORDS.reduce(text) { |acc, word| acc.gsub(word, "") }.squish
  end
  
  def best_match(text)
    matcher.find(text)&.first || text
  end
  
  def matcher
    @matcher ||= begin
      names = ActiveProduct.distinct(:productname)
      FuzzyMatch.new(names, read: :to_s)
    end
  end
end
