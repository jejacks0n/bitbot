require "open-uri"

module Bitbot
  module RestClient
    module Users
      def self.info(user_id)
        user_id = user_id.gsub(/^(?:<@)?([^>]*)(?:>)?$/, "\1")
        JSON.parse(open("https://slack.com/api/users.info?user=#{user_id}&token=#{ENV['APP_API_TOKEN']}").read)
      end
    end
  end
end
