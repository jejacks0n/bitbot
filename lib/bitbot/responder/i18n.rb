module Bitbot
  class Responder
    module I18n
      def t(*args)
        ::I18n.translate(*args)
      end
    end
  end
end
