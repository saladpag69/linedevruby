class ChatController < ApplicationController
  # before_action :authenticate_user!, except: [ :index ]  # Temporarily disabled
  layout "siamcosmo"
  before_action :set_locale
  skip_before_action :verify_authenticity_token, only: [ :create_message, :calculate ]

  def index
    @service = Service.find_by(key: params[:service_id])
    @service ||= Service.find_by(key: "calculator")

    # Get or create session (using guest session if not logged in)
    session_id = session[:guest_session_id] ||= SecureRandom.hex(8)
    @session = ChatSession.find_or_initialize_by(session_key: session_id, service_id: @service.id) do |s|
      s.status = "active"
      s.save!
    end

    if @session.persisted?
      @messages = @session.messages.order(created_at: :asc)
    else
      @messages = []
    end

    # Show greeting for new session
    @greeting = @service&.greeting_message if @messages.empty?

    # For calculator service, load calculator inputs
    if @service.key == "calculator"
      @shapes = [ "rectangle", "triangle", "trapezoid", "circle" ]
    end
  end

  def create_message
    @service = Service.find_by(key: params[:service_key] || params[:service_id])
    return render(json: { error: "Service not found" }, status: 404) unless @service

    # Get or create session
    session_id = session[:guest_session_id] ||= SecureRandom.hex(8)
    @session = ChatSession.find_or_initialize_by(session_key: session_id, service_id: @service.id) do |s|
      s.status = "active"
      s.save!
    end

    # Save user message
    if @session.persisted? && params[:message].present?
      @session.messages.create!(
        role: "user",
        content: params[:message]
      )

      # Generate bot response based on service
      bot_response = generate_bot_response(params[:message], @service)

      @session.messages.create!(
        role: "bot",
        content: bot_response[:content],
        suggestions: bot_response[:suggestions]
      )
    end

    render json: { success: true }
  end

  def calculate
    # Direct calculation endpoint for calculator service
    service = Service.find_by(key: "calculator")
    return render(json: { error: "Calculator not found" }, status: 404) unless service

    result = case params[:shape]
    when "rectangle"
      area = params[:width].to_f * params[:length].to_f
      { area: area.round(2), text: "พื้นที่สี่เหลี่ยม = #{area.round(2)} ตร.ม." }
    when "triangle"
      area = 0.5 * params[:base].to_f * params[:height].to_f
      { area: area.round(2), text: "พื้นที่สามเหลี่ยม = #{area.round(2)} ตร.ม." }
    when "trapezoid"
      area = 0.5 * (params[:parallel1].to_f + params[:parallel2].to_f) * params[:height].to_f
      { area: area.round(2), text: "พื้นที่สี่เหลี่ยมคางหมู = #{area.round(2)} ตร.ม." }
    when "circle"
      area = Math::PI * params[:radius].to_f**2
      { area: area.round(2), text: "พื้นที่วงกลม = #{area.round(2)} ตร.ม." }
    else
      { area: 0, text: "ไม่รู้จักรูปร่างนี้" }
    end

    # Save calculation to chat
    session_id = session[:guest_session_id] ||= SecureRandom.hex(8)
    session = ChatSession.find_or_initialize_by(session_key: session_id, service_id: service.id)
    session.status = "active"
    session.save!

    session.messages.create!(
      role: "bot",
      content: result[:text],
      suggestions: [ t("view_all"), t("contact"), t("request_quote") ]
    )

    render json: result
  end

  private

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def generate_bot_response(user_message, service)
    suggestions = if service.suggestions.present?
      service.suggestions.map { |s| I18n.locale == :th ? s[:th] : s[:en] }.take(4)
    else
      [ t("view_all"), t("contact"), t("request_quote") ]
    end

    response = service.greeting_message || "สวัสดิครับ! ผมช่วยอะไรได้บ้าง?"

    # Simple keyword matching
    msg = user_message.downcase
    if service.key == "calculator"
      if msg.include?("สี่เหลี่ยม") || msg.include?("rectangle")
        response = "กรุณากรอก กว้าง × ยาว เช่น 5 × 6 เมตร"
      elsif msg.include?("สามเหลี่ยม") || msg.include?("triangle")
        response = "กรุณากรอก ฐาน × สูง เช่น 4 × 3 เมตร"
      elsif msg.include?("วงกลม") || msg.include?("circle")
        response = "กรุณากรอก รัศมี เช่น 3 เมตร"
      end
    end

    { content: response, suggestions: suggestions }
  end
end
