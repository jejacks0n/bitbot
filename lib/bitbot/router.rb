module Bitbot
  class Router

    def route_message(message)
      for responder in responders
        return responder.new.respond_to(message) if responder.responds_to?(message)
      end
      raise Bitbot::NoResponderException, 'No route found'
    end

    private

    def responders
      Bitbot.configuration.responders
    end

  end
end
