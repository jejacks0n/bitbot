module Bitbot
  class Responder
    module Confirmable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def awaiting_confirmation_for(message)
          retrieve_message(message)
        end
      end

      delegate :awaiting_confirmation_for, to: :class

      def confirm(prompt, confirm = "yes", &block)
        return block.call if message.forced?

        if confirmable = awaiting_confirmation_for(message)
          remove_message
          return respond_to(confirmable.force!) if message.raw_text == confirm
          respond_with(not_confirmed_message)
        else
          store_message
          respond_with(confirmation_message(prompt, confirm))
        end
      end

      def confirmation_message(prompt, confirm)
        text = "Please confirm with `#{confirm}`. You can say `no` or `cancel` to cancel."
        {
          text: ":warning: Whoa #{message.user_name}, #{prompt}",
          attachments: [{ fallback: text, text: text, color: "#FFBB00", mrkdwn_in: ["text"] }]
        }
      end

      def not_confirmed_message
        {
          text: "Okay #{message.user_name}, nothing happened, moving on."
        }
      end
    end
  end
end
