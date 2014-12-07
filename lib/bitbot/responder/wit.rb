module Bitbot
  class Responder
    module Wit

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        attr_accessor :intents

        def intent(intent, route, options = {})
          @wit ||= ::Wit::REST::Client.new.session
          @intents ||= {}
          @intents[intent] = options.merge(route: route)
        end

        def route_for(message)
          result = super
          return result if result

          message.wit ||= @wit.send_message(message.sanitized_text.dup)
          for intent, options in @intents.each
            return @routes[options[:route]] if intent == message.wit.intent && message.wit.confidence > 0.75
          end
          false
        end

      end

      private

      def process_args(route, message)
        if message.wit && self.class.intents[message.wit.intent]
          args = []
          entities = self.class.intents[message.wit.intent][:entities] || {}
          entities.each do |name, proc|
            entity = message.wit.entities[name.to_s].try(:first) || {}
            args << (!entity.empty? && proc.is_a?(Proc) ? proc.call(entity) : entity['value']) || ''
          end
          args
        else
          super
        end
      end

    end
  end
end
