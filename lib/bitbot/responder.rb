require "bitbot/responder/dsl"
require "bitbot/responder/confirmable"
require "bitbot/responder/i18n"
require "bitbot/responder/redis"
require "bitbot/responder/wit"

module Bitbot
  class Responder
    include DSL
    include Redis
    include Confirmable
    include I18n

    def self.responds_to?(message)
      !!(awaiting_confirmation_for(message) || route_for(message))
    end

    def self.route_for(message)
      (@routes || {}).each do |_name, options|
        return options if message.command? && message.command == options[:command]

        case options[:match]
        when Regexp then return options if message.text =~ options[:match]
        when String then return options if message.text == options[:match]
        end if options[:match]
      end
      false
    end

    attr_accessor :message

    def respond_to(message)
      message = Bitbot::Message.new(message) if message.is_a?(Hash)
      @message = message
      stored_message = awaiting_confirmation_for(message) || message
      route = self.class.route_for(stored_message)
      return instance_exec(*process_args(route, stored_message), &route[:block]) if route
      raise Bitbot::NoRouteError.new
    end

    protected

      def respond_with(options, &block)
        { parse: "full" }.merge(options_or_text(options, &block))
      end

      def private_message(options, &block)
        Bitbot.announce(options_or_text(options, &block).merge(channel: "@#{message.user_name}"))
      end
      alias_method :direct_message, :private_message

      def announce(options, &block)
        Bitbot.announce(options_or_text(options, &block).merge(channel: "##{message.channel}"))
      end

      def delay(seconds, &block)
        Thread.new do
          sleep(seconds)
          block.call
        end
      end

    private

      def options_or_text(options, &block)
        if options.is_a?(String)
          text = options
          options = {}
          options[:text] = text
        else
          options[:text] = block.call(self) if block_given?
        end
        options
      end

      def process_args(route, message)
        matches = []
        if route[:match].is_a?(Regexp)
          matches = route[:match].match(message.text)
          if matches
            matches = matches.to_a
            matches.shift
          end
        end
        matches
      end
  end
end
