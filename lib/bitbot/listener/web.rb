require "rack"

module Bitbot
  module Listener
    class Web < Bitbot::Listener::Base
      attr_writer :path, :port

      def initialize
        super

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
        raise Bitbot::BadRequestError.new unless (req = verified_request(env))
        message = Bitbot::Message.new(req.params)
        response = router.route_message(message)
        ["200", { "Content-Type" => "application/json" }, [response.to_json]]
      rescue Bitbot::Response => e then respond_with_exception(e)
      rescue Bitbot::Error then respond_to_invalid
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
    end
  end
end
