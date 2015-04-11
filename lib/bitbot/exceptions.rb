module Bitbot
  class Error < StandardError
  end

  class Response < Bitbot::Error
  end

  class BadRequestError < Bitbot::Error
  end

  class NoRouteError < Bitbot::Error
    def message
      "Unable to respond, no route found for message."
    end
  end

  class NoResponderError < Bitbot::Error
    def message
      "No route found."
    end
  end

  class NoRedisError < Bitbot::Error
  end
end
