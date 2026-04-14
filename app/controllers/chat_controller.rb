class ChatController < ApplicationController
  # before_action :authenticate_user!, except: [ :index ]  # Temporarily disabled
  layout "siamcosmo"
  before_action :set_locale
  skip_before_action :verify_authenticity_token, only: [ :create_message, :calculate ]

  def providers
    @providers = Provider.active.where.not(service_id: nil).joins(:service).order("providers.created_at DESC")
  end

  def contractors
    contractor_service = Service.find_by(key: "contractor")
    if contractor_service
      @contractors = Provider.active.where(service_id: contractor_service.id).order("rating DESC, jobs_completed DESC")
    else
      @contractors = []
    end
  end

  def transport
    transport_service = Service.find_by(key: "transport")
    if transport_service
      @contractors = Provider.active.where(service_id: transport_service.id).order("rating DESC, jobs_completed DESC")
    else
      @contractors = []
    end
  end

  def rental
    rental_service = Service.find_by(key: "rental")
    if rental_service
      @contractors = Provider.active.where(service_id: rental_service.id).order("rating DESC, jobs_completed DESC")
    else
      @contractors = []
    end
  end

  def documents
    @categories = [
      {
        key: "ก่อสร้าง",
        title: "📋 เอกสารก่อสร้าง",
        description: "เอกสารที่เกี่ยวข้องกับการก่อสร้างอาคาร บ้าน และโครงสร้าง",
        icon: "🏗️",
        documents: [
          { name: "คำขออนุญาตก่อสร้าง", description: "แบบคำขออนุญาตก่อสร้างอาคาร (แบบ ก.1)", url: "#" },
          { name: "รายการประกอบแบบ", description: "รายการประกอบแบบแปลน", url: "#" },
          { name: "ใบอนุญาตก่อสร้าง", description: "ใบอนุญาตก่อสร้างจากทางราชการ", url: "#" },
          { name: "ใบเสร็จรับเงินค่าธรรมเนียม", description: "หลักฐานการชำระค่าธรรมเนียม", url: "#" },
          { name: "สัญญาจ้างงาน", description: "สัญญาจ้างผู้รับเหมาก่อสร้าง", url: "#" },
          { name: "แบบแปลนสถาปัตยกรรม", description: "แบบแปลนชั้นต่างๆ ของอาคาร", url: "#" },
          { name: "รายการวัสดุ", description: "รายการวัสดุที่ใช้ในการก่อสร้าง", url: "#" },
          { name: "อนุญาตดัดแปลงอาคาร", description: "ใบอนุญาตดัดแปลงอาคาร", url: "#" }
        ]
      },
      {
        key: "บริการ",
        title: "📄 เอกสารคำขอบริการ",
        description: "คำขอบริการต่างๆ ในประเทศไทย",
        icon: "📝",
        documents: [
          { name: "คำขอรับใบอนุญาตประกอบกิจการ", description: "คำขอใบอนุญาตประกอบธุรกิจ", url: "#" },
          { name: "คำขอจดทะเบียนพาณิชย์", description: "คำขอจดทะเบียนพาณิชย์", url: "#" },
          { name: "คำขอเปลี่ยนแปลงข้อมูล", description: "คำขอแก้ไขข้อมูลในทะเบียน", url: "#" },
          { name: "คำขอต่ออายุใบอนุญาต", description: "คำขอต่ออายุใบอนุญาต", url: "#" },
          { name: "คำขอยกเลิกใบอนุญาต", description: "คำขอยกเลิกใบอนุญาต", url: "#" },
          { name: "คำขอขึ้นทะเบียนผู้ประกอบวิชาชีพ", description: "คำขอขึ้นทะเบียนวิชาชีพ", url: "#" }
        ]
      },
      {
        key: "สัญญา",
        title: "📜 สัญญาจ้างงาน",
        description: "แบบฟอร์มสัญญาจ้างต่างๆ",
        icon: "📑",
        documents: [
          { name: "สัญญาจ้างงานก่อสร้าง", description: "สัญญาจ้างผู้รับเหมาก่อสร้าง", url: "#" },
          { name: "สัญญาจ้างแรงงาน", description: "สัญญาจ้างลูกจ้าง", url: "#" },
          { name: "สัญญาจ้างที่ปรึกษา", description: "สัญญาจ้างที่ปรึกษาโครงการ", url: "#" },
          { name: "สัญญาจ้างบริการ", description: "สัญญาจ้างบริการทั่วไป", url: "#" },
          { name: "สัญญาจ้างต่อเติม", description: "สัญญาจ้างต่อเติมอาคาร", url: "#" },
          { name: "สัญญาอนุญาตใช้สิทธิ", description: "สัญญาอนุญาตใช้สิทธิ", url: "#" }
        ]
      },
      {
        key: "ที่ดิน",
        title: "🏠 สัญญาจะซื้อจะขายที่ดิน",
        description: "แบบฟอร์มสัญญาที่เกี่ยวกับที่ดิน",
        icon: "🏡",
        documents: [
          { name: "สัญญาจะซื้อจะขายที่ดิน", description: "สัญญาจะซื้อจะขายที่ดิน", url: "#" },
          { name: "สัญญาเช่าที่ดิน", description: "สัญญาเช่าที่ดิน", url: "#" },
          { name: "สัญญาจำนอง", description: "สัญญาจำนองที่ดิน", url: "#" },
          { name: "สัญญาประกัน", description: "สัญญาประกันภัยที่ดิน", url: "#" },
          { name: "หนังสือมอบอำนาจ", description: "มอบอำนาจเกี่ยวกับที่ดิน", url: "#" },
          { name: "ใบมอบอำนาจจดทะเบียน", description: "มอบอำนาจจดโอนที่ดิน", url: "#" }
        ]
      }
    ]
  end

  def projects
    @categories = [
      {
        key: "บ้าน",
        title: "งานก่อสร้างบ้าน",
        icon: "🏠",
        projects: [
          { name: "บ้านเดี่ยว 2 ชั้น ต.บางพลี", value: "850,000", duration: "90 วัน", warranty: "2 ปี", provider: "บจก. สยามสร้างไทย", images: [ "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=400&h=300&fit=crop" ] },
          { name: "บ้านพร้อมอู่ ต.สามพราน", value: "1,200,000", duration: "120 วัน", warranty: "3 ปี", provider: "บจก. รับเหมา สมศรี", images: [ "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600573472591-ee6c563aaec8?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=400&h=300&fit=crop" ] },
          { name: "บ้านแฝด 1 ชั้น ต.บางนา", value: "650,000", duration: "75 วัน", warranty: "1 ปี", provider: "ช่างสมศักดิ์", images: [ "https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600210492493-0946911120ea?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop" ] }
        ]
      },
      {
        key: "ต่อเติม",
        title: "งานต่อเติม",
        icon: "🔨",
        projects: [
          { name: "ต่อเติมหลังคาโรงรถ ต.บางกะสอ", value: "120,000", duration: "14 วัน", warranty: "1 ปี", provider: "บจก. ช่างชูวิทย์", images: [ "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=400&h=300&fit=crop" ] },
          { name: "ต่อเติมห้องนอนชั้น 2 ต.ท่าทราย", value: "350,000", duration: "30 วัน", warranty: "2 ปี", provider: "บจก. สยามรีโนเวท", images: [ "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600573472591-ee6c563aaec8?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=400&h=300&fit=crop" ] },
          { name: "สร้างชั้นล่างเพิ่ม ต.สามพราน", value: "480,000", duration: "45 วัน", warranty: "2 ปี", provider: "บจก. รับเหมา เจริญ", images: [ "https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600210492493-0946911120ea?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop" ] }
        ]
      },
      {
        key: "ไฟฟ้า",
        title: "งานไฟฟ้า",
        icon: "⚡",
        projects: [
          { name: "ติดตั้งระบบไฟฟ้าภายในบ้าน ต.บางนา", value: "85,000", duration: "7 วัน", warranty: "1 ปี", provider: "ช่างไฟ สมชาย", images: [ "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=400&h=300&fit=crop" ] },
          { name: "ติดตั้งมิเตอร์ไฟฟ้า 3 เฟส ต.สามพราน", value: "45,000", duration: "3 วัน", warranty: "1 ปี", provider: "บจก. ไฟฟ้าพร้อม", images: [ "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600573472591-ee6c563aaec8?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=400&h=300&fit=crop" ] },
          { name: "ติดตั้งสายไฟในโรงงาน ต.บางพลี", value: "180,000", duration: "21 วัน", warranty: "2 ปี", provider: "บจก. อมรไฟฟ้า", images: [ "https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600210492493-0946911120ea?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop" ] }
        ]
      },
      {
        key: "ประปา",
        title: "งานประปา",
        icon: "🚰",
        projects: [
          { name: "ติดตั้งระบบประปาภายในบ้าน ต.บางกะสอ", value: "65,000", duration: "5 วัน", warranty: "1 ปี", provider: "ช่างประปา สมหมาย", images: [ "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=400&h=300&fit=crop" ] },
          { name: "ติดตั้งถังเก็บน้ำ 1000 ลิตร ต.ท่าทราย", value: "35,000", duration: "2 วัน", warranty: "1 ปี", provider: "บจก. ประปาสมชิด", images: [ "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600573472591-ee6c563aaec8?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=400&h=300&fit=crop" ] },
          { name: "วางท่อน้ำประปาหมู่บ้าน ต.สามพราน", value: "420,000", duration: "60 วัน", warranty: "3 ปี", provider: "บจก. รับเหมาประปา", images: [ "https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600210492493-0946911120ea?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop" ] }
        ]
      },
      {
        key: "โซล่า",
        title: "งานติดตั้งแผงโซล่าเซล",
        icon: "☀️",
        projects: [
          { name: "ติดตั้งโซล่าเซลหลังคา 8 kW ต.บางนา", value: "280,000", duration: "7 วัน", warranty: "5 ปี", provider: "บจก. โซล่าร์พลังงาน", images: [ "https://images.unsplash.com/photo-1509391366360-2e959784a276?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1508514177221-188b1cf2f26f?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1613665813446-82a78c468a1d?w=400&h=300&fit=crop" ] },
          { name: "ติดตั้งโซล่าเซลโรงงาน 50 kW ต.บางพลี", value: "1,450,000", duration: "21 วัน", warranty: "5 ปี", provider: "บจก. ซันไบรท์ เอ็นเนอร์ยี", images: [ "https://images.unsplash.com/photo-1508514177221-188b1cf2f26f?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1613665813446-82a78c468a1d?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1509391366360-2e959784a276?w=400&h=300&fit=crop" ] },
          { name: "ติดตั้งโซล่าเซลบ้านพักอาศัย 5 kW ต.สามพราน", value: "180,000", duration: "5 วัน", warranty: "5 ปี", provider: "บจก. เอ็กซ์โซลาร์", images: [ "https://images.unsplash.com/photo-1613665813446-82a78c468a1d?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1508514177221-188b1cf2f26f?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1509391366360-2e959784a276?w=400&h=300&fit=crop" ] }
        ]
      },
      {
        key: "ถนน",
        title: "งานเทถนนคอนกรีตพร้อมวางท่อ",
        icon: "🛣️",
        projects: [
          { name: "เทถนนคอนกรีต 500 ตร.ม. ต.บางกะสอ", value: "380,000", duration: "15 วัน", warranty: "2 ปี", provider: "บจก. ถนนไทย สร้าง", images: [ "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=400&h=300&fit=crop" ] },
          { name: "วางท่อระบายน้ำ 200 เมตร ต.ท่าทราย", value: "220,000", duration: "14 วัน", warranty: "3 ปี", provider: "บจก. สุขสว่างรับเหมา", images: [ "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600573472591-ee6c563aaec8?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=400&h=300&fit=crop" ] },
          { name: "เทพื้นลานจอดรถ 300 ตร.ม. ต.สามพราน", value: "280,000", duration: "10 วัน", warranty: "2 ปี", provider: "บจก. คอนกรีตพร้อม", images: [ "https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600210492493-0946911120ea?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop" ] }
        ]
      },
      {
        key: "กล้อง",
        title: "งานติดตั้งกล้องวงจรปิด",
        icon: "📹",
        projects: [
          { name: "ติดตั้งกล้อง 4 ตัว บ้านพัก ต.บางนา", value: "35,000", duration: "2 วัน", warranty: "2 ปี", provider: "บจก. กล้องวงจรปิด พรีเมียร์", images: [ "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&h=300&fit=crop" ] },
          { name: "ติดตั้งกล้อง 16 ตัว สำนักงาน ต.บางพลี", value: "120,000", duration: "5 วัน", warranty: "3 ปี", provider: "บจก. เซฟการ์ด ไทยแลนด์", images: [ "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600573472591-ee6c563aaec8?w=400&h=300&fit=crop" ] },
          { name: "ติดตั้งระบบ AI Camera โรงงาน ต.สามพราน", value: "250,000", duration: "10 วัน", warranty: "3 ปี", provider: "บจก. สมาร์ทเซฟตี้", images: [ "https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600210492493-0946911120ea?w=400&h=300&fit=crop" ] }
        ]
      },
      {
        key: "คอมพิวเตอร์",
        title: "งานวางระบบคอมพิวเตอร์โรงเรียน",
        icon: "💻",
        projects: [
          { name: "ติดตั้งระบบเครือข่าย 50 เครื่อง ต.บางกะสอ", value: "180,000", duration: "14 วัน", warranty: "2 ปี", provider: "บจก. ไอที โซลูชันส์", images: [ "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&h=300&fit=crop" ] },
          { name: "ติดตั้ง WiFi โรงเรียน 30 จุด ต.ท่าทราย", value: "95,000", duration: "7 วัน", warranty: "2 ปี", provider: "บจก. เน็ตเวิร์ค เซอร์วิส", images: [ "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600573472591-ee6c563aaec8?w=400&h=300&fit=crop" ] },
          { name: "วางระบบ LAN ห้องเรียน 20 ห้อง ต.สามพราน", value: "320,000", duration: "21 วัน", warranty: "3 ปี", provider: "บจก. ดาต้า คอมมิวนิเคชั่น", images: [ "https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1600210492493-0946911120ea?w=400&h=300&fit=crop" ] }
        ]
      }
    ]
  end

  def index
    @service = Service.find_by(key: params[:service_id])
    @service ||= Service.find_by(key: "calculator")

    if @service.key == "calculator"
      redirect_to "/calculator" and return
    elsif @service.key == "price"
      redirect_to "/products" and return
    end

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
