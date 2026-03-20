ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"

if ENV["RAILS_ENV"] == "production"
  ENV["RAILS_LOG_LEVEL"] ||= "info"
end

# Ruby 3.4 compatibility fix for Rails
unless "".respond_to?(:ends_with?)
  class String
    def ends_with?(*suffixes)
      suffixes.any? { |suffix| self[-suffix.length, suffix.length] == suffix }
    end
  end
end

require "bootsnap/setup"

# Pre-create the logger for production
if ENV["RAILS_ENV"] == "production"
  require "active_support"
  require "active_support/tagged_logging"
  require "active_support/logger"

  # Create a fallback logger that will be used if Rails.logger is nil
  FALLBACK_LOGGER = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
end
