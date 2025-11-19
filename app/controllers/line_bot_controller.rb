# app/controllers/line_bot_controller.rb
class LineBotController < ApplicationController
  skip_before_action :verify_authenticity_token

  def client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: "5rc4Avbnsgnm7U1F/Ok1yFkvl1+nVF70b4SYaG1WBAP2yV9B7YiYM8TPvJUfv7/W7TLFr6i3xHUUdNGm7H0vJZXS/gelZkRduXqpCqbN42E5l8Wu4M+wInc4yg+qxuhiYpBpwVUY8gdqwYwxUHjIpQdB04t89/1O/w1cDnyilFU="
    )
  end

  def parser
    @parser ||= Line::Bot::V2::WebhookParser.new(
      channel_secret: "2f93e390fa625b298c1278286de6f167"
    )
  end

  def callback
    body      = request.raw_post
    signature = request.env["HTTP_X_LINE_SIGNATURE"]

    begin
      events = parser.parse(body: body, signature: signature)        
    rescue Line::Bot::V2::WebhookParser::InvalidSignatureError
      render plain: "Bad Request", status: 400 and return
    end
    
    events.each do |event|
    case event
    when Line::Bot::V2::Webhook::MessageEvent
    case event.message
    when Line::Bot::V2::Webhook::TextMessageContent
      # ดึงข้อความที่ user พิมพ์
      user_text = event.message.text

      # เตรียมข้อความตอบกลับ
      reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
        reply_token: event.reply_token,
        messages: [
          Line::Bot::V2::MessagingApi::TextMessage.new(
            text: "คุณพิมพ์ว่า: #{user_text}"
          )
        ]
      )

      # ส่งข้อความตอบกลับ
      client.reply_message(reply_message_request: reply_req)
    end

    when Line::Bot::V2::Webhook::FollowEvent
    # เมื่อ user กด Add friend
    reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
      reply_token: event.reply_token,
      messages: [
        Line::Bot::V2::MessagingApi::TextMessage.new(text: "ขอบคุณที่แอดเป็นเพื่อนครับ 🙏")
      ]
    )

    client.reply_message(reply_message_request: reply_req)

    when Line::Bot::V2::Webhook::UnfollowEvent
    Rails.logger.info "ผู้ใช้คนหนึ่งบล็อกบอท ❌"

    when Line::Bot::V2::Webhook::PostbackEvent
    data = event.postback.data

    reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
      reply_token: event.reply_token,
      messages: [
        Line::Bot::V2::MessagingApi::TextMessage.new(text: "ได้รับ postback: #{data}")
      ]
    )

    client.reply_message(reply_message_request: reply_req)
   end
  end

    render plain: "OK"
  end
end
