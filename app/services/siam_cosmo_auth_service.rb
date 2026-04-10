class SiamCosmoAuthService
  BASE_URL = ENV.fetch("SIAMCOSMO_BASE_URL", "http://localhost:5001")
  STATIC_TOKEN = ENV.fetch("SIAMCOSMO_STATIC_TOKEN", "d84fd42ff9cb84d9541c047ecd41fd62593ece34ab148e8c8a81750992c5c76e")
  SHOP_ID = ENV.fetch("SIAMCOSMO_SHOP_ID", "branch_001")

  def self.login(username:, password:)
    new.login(username: username, password: password)
  end

  def login(username:, password:, timeout: 10)
    uri = URI("#{BASE_URL}/api/v1/user/login")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = timeout
    http.read_timeout = timeout

    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(
      username: username,
      password: password,
      shop_id: SHOP_ID,
      static_token: STATIC_TOKEN
    )

    response = http.request(request)
    parse_response(response)
  rescue Net::OpenTimeout, Net::ReadTimeout
    Failure.new(message: "Connection timeout. Please try again.")
  rescue JSON::ParserError
    Failure.new(message: "Invalid response from server.")
  rescue StandardError => e
    Failure.new(message: "Connection error: #{e.message}")
  end

  private

  def parse_response(response)
    body = JSON.parse(response.body)

    if body["result"] == "ok"
      Success.new(
        token: body["token"],
        user: body["user"],
        shoplistid: body["shoplistid"]
      )
    else
      Failure.new(message: body["message"] || "Login failed")
    end
  end

  class Success
    attr_reader :token, :user, :shoplistid

    def initialize(token:, user:, shoplistid:)
      @token = token
      @user = user
      @shoplistid = shoplistid
    end
  end

  class Failure
    attr_reader :message

    def initialize(message:)
      @message = message
    end
  end
end
