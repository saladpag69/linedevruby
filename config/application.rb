require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Siamcosmo
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])
    config.before_eager_load do
      Rails.autoloaders.main.ignore(Rails.root.join("app/example"))
    end

    config.after_initialize do
      if Rails.logger.nil? && defined?(FALLBACK_LOGGER)
        Rails.logger = FALLBACK_LOGGER
      end
    end
  end
end

# Monkey patch Rails.logger to use fallback if nil
module Rails
  class << self
    def logger
      @logger ||= (defined?(FALLBACK_LOGGER) ? FALLBACK_LOGGER : nil)
    end
  end
end
