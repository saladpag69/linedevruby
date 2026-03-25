# app/controllers/line_bot_controller.rb
# U176f407b7ae6cbaeb9bc9ba33ebbc067 == Line สยาม
require "openssl"
require "cgi"
require "ostruct"

class LineBotController < ApplicationController
  include LineBotHandler
  skip_before_action :verify_authenticity_token

  def callback
    body      = request.raw_post
    signature = request.env["HTTP_X_LINE_SIGNATURE"]

    begin
      events = parser.parse(body: body, signature: signature)
    rescue Line::Bot::V2::WebhookParser::InvalidSignatureError
      render plain: "Bad Request", status: 400 and return
    end

    events.each do |event|
      next if event.delivery_context&.is_redelivery

      case event
      when Line::Bot::V2::Webhook::MessageEvent
        case event.message
        when Line::Bot::V2::Webhook::TextMessageContent
          handle_text_event(event)
        end
      when Line::Bot::V2::Webhook::FollowEvent
        handle_follow_event(event)
      when Line::Bot::V2::Webhook::UnfollowEvent
        Rails.logger.info "ผู้ใช้คนหนึ่งบล็อกบอท ❌"
      when Line::Bot::V2::Webhook::PostbackEvent
        handle_postback_event(event)
      end
    end

    render plain: "OK"
  end

  private

  def client
    verify_callback = lambda do |preverify_ok, store_context|
      next true if preverify_ok
      if store_context&.error == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL
        Rails.logger.warn("LINE API SSL verification skipped missing CRL for #{store_context.current_cert.subject}")
        true
      else
        false
      end
    end

    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: Rails.application.credentials.channel_access_token,
      http_options: {
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        verify_callback: verify_callback
      }
    )
  end

  def parser
    @parser ||= Line::Bot::V2::WebhookParser.new(
      channel_secret: Rails.application.credentials.channel_secret
    )
  end
end
