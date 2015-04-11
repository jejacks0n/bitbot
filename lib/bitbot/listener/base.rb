module Bitbot
  module Listener
    autoload :Web, "bitbot/listener/web"

    class Base
      def initialize
        yield self if block_given?
        Bitbot.log("Warning, no outgoing slack token provided.") unless @token
      end

      private

      def router
        @router ||= Bitbot::Router.new
      end

      def verified_request(env)
        req = Rack::Request.new(env)
        return false unless req.post? && req.path == @path                     # only posts at the desired path
        return false unless req["text"].is_a?(String)                          # no empty messages
        return false unless req["user_name"] != Bitbot.configuration.user_name # no replies to myself
        return false unless valid_token?(req["token"])                         # no messages not from slack
        req
      end

      def valid_token?(token)
        if @token.is_a?(Array)
          @token.include?(token)
        else
          @token == token
        end
      end
    end
  end
end
