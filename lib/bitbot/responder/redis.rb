require "redis"

module Bitbot
  class Responder
    module Redis
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def connection
          @connection ||= begin
            connection = Bitbot.configuration.redis_connection
            connection = connection.is_a?(Proc) ? connection.call : connection
            raise Bitbot::NoRedisError.new unless connection
            connection
          end
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

        def key_for_redis(message)
          ["bitbot", message.user_name, message.channel, message.channel_id, name].join(":")
        end
      end
    end

    delegate :connection, to: :class

    def store_message
      self.class.store_message(message)
    end

    def retrieve_message
      self.class.retrieve_message(message)
    end

    def remove_message
      self.class.remove_message(message)
    end
  end
end
