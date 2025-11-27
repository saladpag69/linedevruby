# app/services/nlu/nlp_engine.rb
module Nlu
  class NlpEngine
    def self.call(text:)
      new(text).call
    end

    def initialize(text)
      @raw_text = text.to_s
      @text = text.to_s.downcase
    end

    def call
      {
        entities: {
          product: detect_product,
          size: detect_size,
          quantity: detect_quantity
        }.compact
      }
    end

    private

    def detect_product
      text = @text
      dictionary = {
          "ปูน" => ["ปูนซีเมนต์", "ปูนฉาบ", "ปูนสำเร็จรูป", "ปูนก่อ"],
          "เหล็ก" => ["เหล็กกล่อง", "เหล็กเส้น", "เหล็กตัวซี"],
          "วงส้วม" => ["วงส้วม", "วงโถส้วม"],
          "ท่อ" => ["ท่อ PVC", "ท่อประปา", "ท่อเหล็ก"],
          "สี" => ["สีทาบ้าน", "สีน้ำมัน", "สีรองพื้น"],
          "ไม้" => ["ไม้แบบ", "ไม้อัด", "ไม้ระแนง"],
          "อิฐ" => ["อิฐมอญ", "อิฐบล็อก", "อิฐแดง"],
          "กระเบื้อง" => ["กระเบื้องปูพื้น", "กระเบื้องหลังคา"]
        }
        
      # return "วงส้วม" if @text.include?("วงส้วม") || @text.include?("วงโถส้วม")
      dictionary.each do |key, list|
         return list.first if text.include?(key)
       end
      # ขั้น advance:
      # names = Product.pluck(:name) แล้วหาอันที่ text include
      nil
    end

    def detect_size
      text = @text
    
      result = {}
    
      # 1) ความหนา (mm)
      if text =~ /(\d+(\.\d+)?)\s*(มม|mm|มิลลิเมตร)/
        result[:thickness_mm] = $1.to_f
      end
    
      # 2) ความยาว (เมตร)
      if text =~ /(\d+(\.\d+)?)\s*(ม\.?|เมตร|m)\b/
        result[:length_m] = $1.to_f
      end
    
      # 3) ความกว้าง (cm)
      if text =~ /(\d+(\.\d+)?)\s*(ซม|cm|เซนติเมตร)/
        result[:width_cm] = $1.to_f
      end
    
      # 4) ขนาดนิ้ว / ท่อ PVC / เหล็กกล่อง
      if text =~ /(\d+(\.\d+)?)(\/\d+)?\s*(\"|นิ้ว)\b/
        result[:inch] = $1
      end
    
      # 5) ขนาดแบบ AxB เช่น 1x2 นิ้ว, 2x4 ม., 1.2x2.4 ม.
      if text =~ /(\d+(\.\d+)?)\s*[x×]\s*(\d+(\.\d+)?)/i
        result[:size_pair] = {
          a: $1.to_f,
          b: $3.to_f
        }
      end
    
      # 6) ดึงตัวเลขทั้งหมด สำหรับกรณีทั่วไป เช่น "เหล็กเส้น 12"
      all_numbers = text.scan(/\d+(\.\d+)?/).flatten.map(&:to_f)
      result[:all_numbers] = all_numbers unless all_numbers.empty?
    
      # 7) ถ้าเจอ “วง” ตามหลังตัวเลข → เป็นจำนวน ไม่ใช่ขนาด
      if text =~ /(\d+)\s*วง/
        result[:quantity] = $1.to_i
      end
    
      # ถ้าไม่มีข้อมูลที่มีความหมาย → return nil
      return nil if result.empty?
    
      result
    end


    def detect_quantity
      text = @text
    
      # แปลงเลขไทยเป็นเลขอารบิกก่อน
      thai_to_arabic = {
        "๐"=>"0","๑"=>"1","๒"=>"2","๓"=>"3","๔"=>"4",
        "๕"=>"5","๖"=>"6","๗"=>"7","๘"=>"8","๙"=>"9"
      }
      normalized_text = text.tr(thai_to_arabic.keys.join, thai_to_arabic.values.join)
    
      # หน่วยที่ใช้ในร้านวัสดุก่อสร้าง
      units = %w[
        วง เส้น มัด ถุง ท่อน แผ่น กล่อง ก้อน แกลลอน
        ถัง คิว ม้วน ชิ้น แผง กระสอบ พาเลท
      ]
    
      # ทำ regex สำหรับทุกหน่วย เช่น (\d+)\s*(วง|เส้น|ถุง|...)
      unit_pattern = units.join("|")
      regex = /(\d+)\s*(#{unit_pattern})/
    
      if (m = normalized_text.match(regex))
        {
          quantity: m[1].to_i,
          unit: m[2]
        }
      else
        nil
      end
    end

  end
end
