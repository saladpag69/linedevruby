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
      events = if Rails.env.development?
                 parse_events_dev(body)
      else
                 begin
                   parser.parse(body: body, signature: signature)
                 rescue Line::Bot::V2::WebhookParser::InvalidSignatureError
                   render plain: "Bad Request", status: 400 and return
                 end
      end
    rescue => e
      Rails.logger.error "❌ callback error: #{e.message} #{e.backtrace.first(3).join}"
      render plain: "OK" and return
    end

    return render plain: "OK" if events.empty?

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
      channel_access_token: ENV["CHANNEL_ACCESS_TOKEN"],
      http_options: {
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        verify_callback: verify_callback
      }
    )
  end

  def parser
    @parser ||= Line::Bot::V2::WebhookParser.new(
      channel_secret: ENV["CHANNEL_SECRET"]
    )
  end

  def parse_events_dev(body)
    json = JSON.parse(body)
    events_data = json["events"] || []

    events = events_data.map do |event_data|
      create_mock_event(event_data)
    end

    Rails.logger.warn "⚠️ Dev mode: parsed #{events.size} events"

    events.each do |event|
      begin
        Rails.logger.warn "⚠️ Dev mode processing event type: #{event.type}"
        case event.type
        when "message"
          handle_text_event(event)
        when "follow"
          handle_follow_event(event)
        when "postback"
          handle_postback_event(event)
        end
      rescue => e
        Rails.logger.error "❌ Event processing error: #{e.message} #{e.backtrace.first(3).join}"
      end
    end

    events
  end

  def create_mock_event(data)
    OpenStruct.new(
      type: data["type"],
      message: OpenStruct.new(
        type: data.dig("message", "type"),
        text: data.dig("message", "text"),
        id: "mock-#{Time.now.to_i}"
      ),
      source: OpenStruct.new(
        user_id: data.dig("source", "userId"),
        type: data.dig("source", "type")
      ),
      reply_token: data["replyToken"],
      delivery_context: nil
    )
  end
end
