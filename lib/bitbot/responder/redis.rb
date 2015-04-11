require "redis"

module Bitbot
  class Responder
    module Redis
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def connection
          return @connection if @connection
          connection = Bitbot.configuration.redis_connection
          connection = connection.is_a?(Proc) ? connection.call : connection
          raise Bitbot::NoRedisError.new unless connection
          connection
        end

        def store_message(message)
          connection.set(key_for_redis(message), message.to_json)
        end

        def retrieve_message(message)
          json = connection.get(key_for_redis(message))
          return nil unless json
          message = JSON.parse(json)
          Bitbot::Message.new(message)
        end

        def remove_message(message)
          connection.del(key_for_redis(message))
        end

        private

        def key_for_redis(message)
          "bitbot:#{message.user_name}:#{message.channel}:#{message.channel_id}:#{name}"
        end
      end
    end

    protected

    delegate :connection, :store_message, :retrieve_message, :remove_message, to: :class
  end
end
