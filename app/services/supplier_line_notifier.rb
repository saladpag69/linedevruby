require "openssl"

class SupplierLineNotifier
  SUPPLIER_LINE_ID = "C825174a05b34cfec346b837944651495"

  def initialize(message:, client: default_client)
    @message = message
    @client = client
  end

  def call
    push_request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
      to: SUPPLIER_LINE_ID,
      messages: [
        Line::Bot::V2::MessagingApi::TextMessage.new(text: message)
      ]
    )

    client.push_message(push_message_request: push_request)
  end

  private

  attr_reader :message, :client

  def default_client
    verify_callback = lambda do |preverify_ok, store_context|
      next true if preverify_ok

      if store_context&.error == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL
        Rails.logger.warn("LINE API SSL verification skipped missing CRL for #{store_context.current_cert.subject}")
        true
      else
        false
      end
    end

    @default_client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: LINE_CHANNEL_ACCESS_TOKEN,
      http_options: {
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        verify_callback: verify_callback
      }
    )
  end
end
