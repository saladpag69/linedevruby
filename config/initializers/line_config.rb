LINE_CHANNEL_SECRET = ENV["LINE_CHANNEL_SECRET"] || Rails.application.credentials.line&.dig(:channel_secret)
LINE_CHANNEL_ACCESS_TOKEN = ENV["LINE_CHANNEL_ACCESS_TOKEN"] || Rails.application.credentials.line&.dig(:channel_access_token)
