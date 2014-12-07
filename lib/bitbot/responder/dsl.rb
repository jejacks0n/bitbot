module Bitbot
  class Responder
    module DSL

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        attr_accessor :category_name, :command_help, :routes

        def category(value)
          @category_name = value
        end

        def help(phrase, options = {})
          @command_help ||= []
          @command_help <<= {phrase: phrase, category: @category}.merge(options)
        end

        def route(name, match, options = {}, &block)
          raise ArgumentError, "Missing block for route #{name}." unless block_given?
          @routes ||= {}
          @routes[name] = options.merge(match: match, block: block)
        end

      end
    end
  end
end
