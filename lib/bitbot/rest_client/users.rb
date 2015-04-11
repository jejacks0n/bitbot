require "open-uri"

module Bitbot
  module RestClient
    module Users
      extend Bitbot::RestClient

      ENDPOINT = "https://slack.com/api/users.info"

      def self.info(user_id)
        user_id = user_id.gsub(/^(?:<@)?([^>]*)(?:>)?$/, '\1')
        JSON.parse(open("#{ENDPOINT}?user=#{user_id}&token=#{token}").read)
      end
    end
  end
end
