require "rack"

module Bitbot
  module Listener
    class Web
      attr_writer :token, :path, :port

      def initialize
        yield self if block_given?
        Bitbot.log("Warning, no outgoing slack token provided.") unless @token

        @path ||= "/"
        @port ||= "9292"
      end

      def listen
        Bitbot.log("Starting web listener at 127.0.0.1:#{@port}")
        Rack::Handler::WEBrick.run(self, Port: @port) do |server|
          [:INT, :TERM].each { |sig| trap(sig) { server.stop } }
        end
      end

      def call(env)
        raise Bitbot::BadRequestException unless (req = verified_request(env))
        message = Bitbot::Message.new(req.params)
        response = router.route_message(message)
        ["200", { "Content-Type" => "application/json" }, [response.to_json]]
      rescue Bitbot::Response => e then respond_with_exception(e)
      rescue BitbotException then respond_to_invalid
      rescue StandardError => e then render_exception(env, req, e)
      end

      protected

      def render_exception(env, req, e)
        handle_exception(Rack::Request.new(env), e)
        return respond_to_invalid unless req # only respond with the exception if the request was ok
        [
          "200",
          { "Content-Type" => "application/json" },
          [{ text: "Oh-uh, we've had some issues: #{e.inspect}" }.to_json]
        ]
      end

      def respond_with_exception(e)
        [
          "200",
          { "Content-Type" => "application/json" },
          [{ text: "Uh-oh, #{e.message}" }.to_json]
        ]
      end

      def respond_to_invalid
        ["204", {}, []]
      end

      def handle_exception(_e, _request)
        # extend the class and add custom handling.
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
