# app/controllers/line_bot_controller.rb
require "openssl"
require "cgi"

class LineBotController < ApplicationController
  skip_before_action :verify_authenticity_token

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
      channel_access_token: "5rc4Avbnsgnm7U1F/Ok1yFkvl1+nVF70b4SYaG1WBAP2yV9B7YiYM8TPvJUfv7/W7TLFr6i3xHUUdNGm7H0vJZXS/gelZkRduXqpCqbN42E5l8Wu4M+wInc4yg+qxuhiYpBpwVUY8gdqwYwxUHjIpQdB04t89/1O/w1cDnyilFU=",
      http_options: {
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        verify_callback: verify_callback
      }
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
          user_text = event.message.text.to_s
          products = ActiveProduct.search(user_text)

          messages = if user_text.strip.empty?
                       [
                         Line::Bot::V2::MessagingApi::TextMessage.new(
                           text: "พิมพ์ชื่อสินค้าหรือบาร์โค้ดเพื่อค้นหาได้เลยครับ"
                         )
                       ]
                     elsif products.empty?
                       [
                         Line::Bot::V2::MessagingApi::TextMessage.new(
                           text: "ไม่พบสินค้า \"#{user_text}\" ในระบบ"
                         )
                       ]
                     else
                       bubbles = build_product_bubbles(products.first(5))
                       [
                         Line::Bot::V2::MessagingApi::FlexMessage.new(
                           alt_text: "ผลการค้นหา #{user_text}",
                           contents: {
                             type: "carousel",
                             contents: bubbles
                           }
                         )
                       ]
                     end

          reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
            reply_token: event.reply_token,
            messages: messages
          )

          client.reply_message(reply_message_request: reply_req)
        end

      when Line::Bot::V2::Webhook::FollowEvent
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

  private

  FALLBACK_PRODUCT_IMAGE = "https://images.unsplash.com/photo-1448630360428-65456885c650"

  def build_product_bubbles(products)
    products.map do |product|
      price_primary = product.productsale1.to_s
      price_secondary = product.productsale2.to_s
      image_url = product.productimage.presence || FALLBACK_PRODUCT_IMAGE

      {
        type: "bubble",
        hero: {
          type: "image",
          url: image_url,
          size: "full",
          aspectRatio: "20:13",
          aspectMode: "cover",
          action: {
            type: "uri",
            uri: request.base_url
          }
        },
        body: {
          type: "box",
          layout: "vertical",
          contents: [
            {
              type: "text",
              text: product.productname.to_s,
              weight: "bold",
              size: "lg",
              wrap: true
            },
            {
              type: "text",
              text: "บาร์โค้ด: #{product.barcodeid}",
              size: "sm",
              color: "#666666",
              wrap: true
            },
            {
              type: "box",
              layout: "vertical",
              margin: "lg",
              spacing: "sm",
              contents: [
                {
                  type: "box",
                  layout: "baseline",
                  spacing: "sm",
                  contents: [
                    { type: "text", text: "ราคาเต็ม", color: "#aaaaaa", size: "sm", flex: 2 },
                    { type: "text", text: "฿#{price_secondary}", size: "sm", color: "#111111", flex: 4 }
                  ]
                },
                {
                  type: "box",
                  layout: "baseline",
                  spacing: "sm",
                  contents: [
                    { type: "text", text: "ราคาพิเศษ", color: "#aaaaaa", size: "sm", flex: 2 },
                    { type: "text", text: "฿#{price_primary}", size: "sm", color: "#0ea5e9", flex: 4 }
                  ]
                },
                {
                  type: "box",
                  layout: "baseline",
                  spacing: "sm",
                  contents: [
                    { type: "text", text: "สต็อก", color: "#aaaaaa", size: "sm", flex: 2 },
                    { type: "text", text: "#{product.productstock} ชิ้น", size: "sm", color: "#111111", flex: 4 }
                  ]
                }
              ]
            }
          ]
        },
        footer: {
          type: "box",
          layout: "vertical",
          spacing: "sm",
          contents: [
            {
              type: "button",
              style: "link",
              height: "sm",
              action: {
                type: "uri",
                label: "เปิดดูสินค้า",
                uri: "#{request.base_url}/aboutus?q=#{CGI.escape(product.productname.to_s)}"
              }
            }
          ],
          flex: 0
        }
      }
    end
  end
end
