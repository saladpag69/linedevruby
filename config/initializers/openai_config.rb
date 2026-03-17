OPENAI_API_KEY = ENV["OPENAI_API_KEY"] || Rails.application.credentials.openai&.dig(:api_key)
