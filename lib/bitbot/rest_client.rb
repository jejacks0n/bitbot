module Bitbot
  module RestClient
    autoload :Users, "bitbot/rest_client/users"

    def token
      Bitbot.configuration.api_token
    end
  end
end
