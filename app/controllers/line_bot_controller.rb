# app/controllers/line_bot_controller.rb
# U176f407b7ae6cbaeb9bc9ba33ebbc067 == Line สยาม
#  == Line Zayam
require "openssl"
require "cgi"
require "ostruct"
require "bundler/setup"
require "openai"

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

      channel_access_token: Rails.application.credentials.line[:channel_access_token],
      http_options: {
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        verify_callback: verify_callback
      }
    )
  end

  def parser
    @parser ||= Line::Bot::V2::WebhookParser.new(
      channel_secret: Rails.application.credentials.line[:channel_secret]
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
          user_id = event.source&.user_id || "unknown"

          Rails.logger.info "🔍 Text user_id: #{user_id}, text: #{user_text}"

          source = event.source
          group_id = if source.is_a?(Line::Bot::V2::Webhook::GroupSource)
                       source.group_id
          elsif source.is_a?(Line::Bot::V2::Webhook::RoomSource)
                       source.room_id
          end

          if group_id == "C825174a05b34cfec346b837944651495"
            reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
              reply_token: event.reply_token,
              messages: [
                Line::Bot::V2::MessagingApi::TextMessage.new(
                  text: "ไม่สามารถตอบคำถามผู้ค้าได้"
                )
              ]

            )
          # Handle the message for the specific user
          else
          reply_token = event.reply_token


          extracted    = MessageProductExtractor.new(user_text).call
          response_text = extracted[:response]

           products = if response_text.present?
                        ActiveProduct.none
           elsif extracted[:barcode].present?
                        ActiveProduct.where(barcodeid: extracted[:barcode])
           elsif extracted[:keyword].present?
                        ActiveProduct.search(extracted[:keyword], unit: extracted[:unit])

           else
                        ActiveProduct.none
           end

                     nlu_result = Nlu::Orchestrator.call(text: user_text, customer: user_id, products: products)
                     llm_message = nlu_result
                     test_parsed = JSON.parse(llm_message) # แปลงเป็น hash
                     test_response = test_parsed.dig("message")
                     test_message =                        [
                       Line::Bot::V2::MessagingApi::TextMessage.new(

                         text: test_response
                       )
                     ]



           messages = if response_text.present?
                        [
                          Line::Bot::V2::MessagingApi::TextMessage.new(
                            text: response_text
                          )
                        ]
           elsif extracted[:intent] == :view_cart
                        build_cart_message(user_id)
           elsif extracted[:intent] == :clear_cart
                        CartService.clear_cart(user_id)
                        [
                          Line::Bot::V2::MessagingApi::TextMessage.new(
                            text: "ล้างตะกร้าเรียบร้อยแล้วครับ 🗑️"
                          )
                        ]
           elsif user_text.strip.empty?
                        [
                          Line::Bot::V2::MessagingApi::TextMessage.new(
                            text: "พิมพ์ชื่อสินค้าหรือบาร์โค้ดเพื่อค้นหาได้เลยครับ"
                          )
                        ]
           elsif products.empty?
                        notify_admin_no_product(user_id: user_id, group_id: group_id, query: user_text)
                        [
                          Line::Bot::V2::MessagingApi::TextMessage.new(
                            text: "ไม่พบสินค้า \"#{extracted[:keyword]}\" ในระบบ"
                          )
                        ]
           elsif extracted[:intent] == :stock || extracted[:intent] == "ASK_STOCK"
                        product = products.first
                        stock = product.productstock.to_i
                        unit_display = extracted[:unit] || product.productunit || "ชิ้น"
                        stock_text = stock.positive? ? "#{stock} #{unit_display}" : "หมด"
                        [
                          Line::Bot::V2::MessagingApi::TextMessage.new(
                            text: "#{product.productname} เหลือ #{stock_text}"
                          )
                        ]
           else

                       bubbles = build_product_bubbles(products)
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



            # Handle the message for another specific user

            reply_messages = messages

            reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
              reply_token: event.reply_token,
              messages: reply_messages
            )
          end

          reply_messages ||= reply_req.messages
          append_chat_message(role: "user", text: user_text)
          reply_messages.each do |message|
            next unless message.respond_to?(:text)

            append_chat_message(role: "ai", text: message.text)
          end
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
        user_id = event.source&.user_id || "unknown"

        Rails.logger.info "🔍 Postback user_id: #{user_id}, data: #{data}"

        params = CGI.parse(data)
        action = params["action"]&.first

        if action == "add_cart"
          product = OpenStruct.new(
            barcodeid: params["sku"]&.first,
            productname: params["name"]&.first,
            productsale1: params["price"]&.first,
            productunit: params["unit"]&.first
          )

          Rails.logger.info "🔍 add_cart - user_id: #{user_id}, sku: #{product.barcodeid}, name: #{product.productname}"

          item = CartService.add_item(user_id, product)

          # Verify cart after add
          summary = CartService.cart_summary(user_id)
          Rails.logger.info "🔍 Cart after add - items: #{summary[:items].map { |i| "#{i.product_name}(#{i.sku})" }.join(', ')}"

          reply_text = "เพิ่มลงตะกร้าแล้ว 🛒 #{item.product_name} x#{item.quantity}\nพิมพ์ ดูตะกร้า หรือ เพิ่มสินค้าต่อได้เลยครับ"
        elsif action == "view_cart"
          reply_messages = build_cart_message(user_id)
          reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
            reply_token: event.reply_token,
            messages: reply_messages
          )
          client.reply_message(reply_message_request: reply_req)
          return
        elsif action == "process_order"
          summary = CartService.cart_summary(user_id)
          if summary.nil? || summary[:items].empty?
            reply_text = "ตะกร้าของคุณว่างเปล่าครับ 🛒\nพิมพ์ชื่อสินค้าเพื่อค้นหาได้เลยครับ"
          else
            reply_text = "รายการสั่งซื้อของคุณ:\n#{summary[:items].map { |i| "• #{i.product_name} x#{i.quantity} = ฿#{(i.price.to_f * i.quantity).round}" }.join("\n")}\n\nราคารวม: ฿#{summary[:total].round} บาท\n\nกรุณาโอนเงินและส่งหลักฐานการโอนเงินครับ"
          end
        elsif action == "clear_cart"
          CartService.clear_cart(user_id)
          reply_text = "ล้างตะกร้าเรียบร้อยแล้วครับ 🗑️"
        else
          reply_text = "ได้รับ postback: #{data}"
        end

        reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
          reply_token: event.reply_token,
          messages: [
            Line::Bot::V2::MessagingApi::TextMessage.new(text: reply_text)
          ]
        )

        client.reply_message(reply_message_request: reply_req)
      end
    end

    render plain: "OK"
  end


  private

  # def create
  #    nlu = Nlu::Orchestrator.call(text: params[:text], customer: current_customer)

  #    response = IntentRouter.call(nlu: nlu, customer: current_customer)

  #    render json: { reply: response }
  #  end

  def notify_admin_no_product(user_id:, group_id:, query:)
    message = "ผู้ใช้:#{user_id} กลุ่ม:#{group_id} สอบถาม \"#{query}\""
    SupplierLineNotifier.new(message: message).call

  rescue StandardError => e
    Rails.logger.error("notify_admin_no_product failed: #{e.message}")
  end

  FALLBACK_PRODUCT_IMAGE = "https://images.unsplash.com/photo-1448630360428-65456885c650"

  def build_product_bubbles(products)
    products.first(5).map do |product|
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
            },
            {
              type: "button",
              style: "primary",
              height: "sm",
              action: {
                type: "postback",
                label: "สั่งซื้อ",
                data: "action=add_cart&sku=#{product.barcodeid}&name=#{CGI.escape(product.productname.to_s)}&price=#{product.productsale1}&unit=#{product.productunit}"
              }
            }
          ],
          flex: 0
        }
      }
    end
  end

  def build_cart_message(user_id)
    Rails.logger.info "🔍 build_cart_message called with user_id: #{user_id}"

    summary = CartService.cart_summary(user_id)

    Rails.logger.info "🔍 Cart summary: #{summary.inspect}"

    if summary.nil? || summary[:items].empty?
      return [
        Line::Bot::V2::MessagingApi::TextMessage.new(
          text: "ตะกร้าของคุณว่างเปล่าครับ 🛒\nพิมพ์ชื่อสินค้าเพื่อค้นหาได้เลยครับ"
        )
      ]
    end

    bubbles = summary[:items].first(5).map do |item|
      {
        type: "bubble",
        body: {
          type: "box",
          layout: "vertical",
          contents: [
            {
              type: "text",
              text: item.product_name,
              weight: "bold",
              size: "lg",
              wrap: true
            },
            {
              type: "text",
              text: "#{item.quantity} #{item.unit} x ฿#{item.price} = ฿#{(item.price.to_f * item.quantity).round}",
              size: "md",
              color: "#666666"
            }
          ]
        }
      }
    end

    total_text = "ราคารวม: ฿#{summary[:total].round} บาท (#{summary[:item_count]} รายการ)"

    quick_reply = {
      items: [
        {
          type: "action",
          action: {
            type: "postback",
            label: "สั่งซื้อ",
            text: "สั่งซื้อ",
            data: "action=process_order"
          }
        },
        {
          type: "action",
          action: {
            type: "postback",
            label: "ดูตะกร้า",
            text: "ดูตะกร้า",
            data: "action=view_cart"
          }
        },
        {
          type: "action",
          action: {
            type: "postback",
            label: "ล้างตะกร้า",
            text: "ล้างตะกร้า",
            data: "action=clear_cart"
          }
        }
      ]
    }

    [
      Line::Bot::V2::MessagingApi::TextMessage.new(text: "🛒 ตะกร้าของคุณ\n\n#{summary[:items].map { |i| "• #{i.product_name} x#{i.quantity} = ฿#{(i.price.to_f * i.quantity).round}" }.join("\n")}\n\n#{total_text}"),
      Line::Bot::V2::MessagingApi::FlexMessage.new(
        alt_text: "ตะกร้าสินค้า",
        contents: {
          type: "carousel",
          contents: bubbles
        }
      ),
      Line::Bot::V2::MessagingApi::TextMessage.new(
        text: "กรุณาเลือกดำเนินการ",
        quickReply: quick_reply
      )
    ]
  end
end
