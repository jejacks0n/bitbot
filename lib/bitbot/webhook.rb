require "uri"
require "net/http"
require "net/https"

module Bitbot
  class Webhook
    def announce(options)
      options[:parse] = "full"
      options[:user_name] = Bitbot.configuration.user_name
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(payload: options.to_json)
      http.request(request)
    rescue URI::InvalidURIError
      Bitbot.log("Unable to announce, invalid webhook_url is present.")
    end

    private

      def http
        @http ||= begin
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http
        end
      end

      def uri
        @uri ||= URI.parse(Bitbot.configuration.webhook_url)
      end
  end
end
