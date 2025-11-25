require "openssl"

class LinePushJob < ApplicationJob
  queue_as :default

  def perform(line_user_id, messages)
      client = line_client

      # ถ้าใช้ SDK v2 แบบใหม่:
      request = {
        to: line_user_id,
        messages: messages
      }
      client.push_message(push_message_request: request)
    end

    private

    def line_client
      @line_client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
        channel_access_token: ENV.fetch("LINE_CHANNEL_ACCESS_TOKEN"),
        # http_options: { verify_mode: OpenSSL::SSL::VERIFY_NONE } # <-- dev only
      )
    end

  def normalize_messages(messages)
    Array(messages).filter_map do |message|
      case message
      when Line::Bot::V2::MessagingApi::TextMessage,
           Line::Bot::V2::MessagingApi::FlexMessage
        message
      when Hash
        type = message[:type] || message["type"]
        case type
        when "text"
          Line::Bot::V2::MessagingApi::TextMessage.new(text: message[:text] || message["text"])
        else
          nil
        end
      when String
        Line::Bot::V2::MessagingApi::TextMessage.new(text: message)
      else
        nil
      end
    end
  end
end
