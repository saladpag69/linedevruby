require "line/bot/v2/http_client"

module Line
  module Bot
    module V2
      class HttpClient
        private

        def perform_request(request:)
          http = Net::HTTP.new(request.uri.hostname, request.uri.port)
          http.use_ssl = request.uri.scheme == "https"

          (@http_options || {}).each do |key, value|
            setter = "#{key}="
            http.public_send(setter, value) if http.respond_to?(setter)
          end
           
          http.start do |connection|
            connection.request(request)
          end
        end
      end
    end
  end
end
