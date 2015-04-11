require "uri"
require "net/http"
require "net/https"

module Bitbot
  class Webhook
    def self.announce(options)
      options.merge!(parse: "full", user_name: Bitbot.configuration.user_name)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(payload: options.to_json)
      http.request(request)
    rescue URI::InvalidURIError
      Bitbot.log("Unable to announce, invalid webhook_url is present.")
    end

    def self.http
      return @http if @http
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      @http
    end

    def self.uri
      @uri ||= URI.parse(Bitbot.configuration.webhook_url)
    end
  end
end
