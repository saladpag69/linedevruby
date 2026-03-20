puts "DEBUG: fix_logger.rb is running at #{Time.now}"
puts "DEBUG: Rails.logger before: #{Rails.logger.class}"
Rails.logger ||= ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
puts "DEBUG: Rails.logger after: #{Rails.logger.class}"
