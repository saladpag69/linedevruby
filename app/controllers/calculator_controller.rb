class CalculatorController < ApplicationController
  before_action :set_locale
  layout "siamcosmo"

  def quick
    @current_step = 1
  end

  def step1
    @service_types = ServiceType.active.sorted
    @current_step = 1
  end

  def step2
    @service_type = ServiceType.find_by(slug: params[:service_type_slug])
    unless @service_type
      redirect_to calculator_path, alert: "ไม่พบประเภทบริการ"
      return
    end

    @inputs = session[:calculator_inputs] || {}
    @current_step = 2
    render :step2
  end

  def step3
    @service_type = ServiceType.find_by(slug: params[:service_type_slug])
    unless @service_type
      redirect_to calculator_path, alert: "ไม่พบประเภทบริการ"
      return
    end

    @inputs = calculator_params.to_h.symbolize_keys
    session[:calculator_inputs] = @inputs
    session[:calculator_service_type] = @service_type.slug

    calculator = QuoteCalculatorService.new(@service_type.slug, @inputs)
    @calc_result = calculator.calculate

    if @calc_result[:error]
      redirect_to calculator_step2_path(service_type_slug: @service_type.slug), alert: @calc_result[:error]
      return
    end

    @contractors = Contractor.available.for_service(@service_type.slug).presence ||
                   Contractor.available.mock.first(3)

    @current_step = 3
    render :step3
  end

  def step4
    @service_type = ServiceType.find_by(slug: params[:service_type_slug])
    unless @service_type
      redirect_to calculator_path, alert: "ไม่พบประเภทบริการ"
      return
    end

    @inputs = session[:calculator_inputs] || calculator_params.to_h.symbolize_keys
    @contractor_id = params[:contractor_id].presence
    @delivery_option = params[:delivery_option] || "pickup"

    @contractor = Contractor.find_by(id: @contractor_id) if @contractor_id.present?

    calculator = QuoteCalculatorService.new(@service_type.slug, @inputs)
    @calc_result = calculator.calculate

    if @calc_result[:error]
      redirect_to calculator_step2_path(service_type_slug: @service_type.slug), alert: @calc_result[:error]
      return
    end

    @quote = calculator.calculate_and_build_quote(
      user: current_user,
      contractor: @contractor,
      delivery_option: @delivery_option
    )

    session[:calculator_quote_id] = @quote.id
    @current_step = 4
    render :step4
  end

  def preview
    service_type_slug = params[:service_type_slug]
    inputs = calculator_params.to_h.symbolize_keys

    calculator = QuoteCalculatorService.new(service_type_slug, inputs)
    result = calculator.calculate

    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: {
        area: result[:area],
        volume: result[:volume],
        materials: result[:materials],
        material_total: result[:material_total],
        labor_total: result[:labor_total],
        formula_preview: result[:formula_preview]
      }
    end
  end

  def pdf
    @quote = Quote.find_by(id: params[:id])
    unless @quote
      redirect_to calculator_path, alert: "ไม่พบใบเสนอราคา"
      return
    end

    respond_to do |format|
      format.html { render layout: false }
      format.pdf do
        render pdf: "quote_#{@quote.id}",
               template: "calculator/pdf",
               layout: "pdf",
               page_size: "A4",
               orientation: "Portrait"
      end
    end
  end

  def send_line
    @quote = Quote.find_by(id: params[:id])
    unless @quote
      render json: { error: "ไม่พบใบเสนอราคา" }, status: :not_found
      return
    end

    if @quote.user.blank? && @quote.line_user_id.blank?
      render json: { error: "กรุณาเข้าสู่ระบบก่อนส่ง PDF ทาง LINE" }, status: :unauthorized
      return
    end

    LinePushJob.perform_later(@quote.line_user_id || @quote.user.line_id, "📄 ใบเสนอราคา #{@quote.id}\nราคารวม: ฿#{@quote.grand_total.to_i}")
    render json: { success: true, message: "กำลังส่ง PDF ทาง LINE..." }
  end

  private

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def calculator_params
    params.permit(:width, :length, :height, :thickness, :depth)
  end
end
