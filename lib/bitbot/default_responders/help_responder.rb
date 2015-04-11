class HelpResponder < Bitbot::Responder
  category "General"
  help "help", description: "You're looking at it"

  route :help, /^help/ do
    private_message(help_message)
    respond_with("Providing help for #{message.user_name} in Private Message.")
  end

  def help_message
    {
      text: "Hello #{message.user_name}, here's what I can do.",
      attachments: [
        {
          fallback: "Unable to display help message on this client.",
          pretext: help_text,
          text: command_help,
          color: "#000000",
          mrkdwn_in: ["text"]
        }
      ]
    }
  end

  def help_text
    <<-MSG.strip_heredoc
      Prefix all commands with `bot`, or `#{Bitbot.configuration.user_name}`.

      So like, tell me do something with `bot run command`.
      I don't do private chat, so do it in a channel.
    MSG
  end

  def command_help
    commands = ""
    responder_categories.each do |key, value|
      commands << "#{key}:\n  #{value.join("\n  ")}\n" if value
    end
    %{```\n#{commands}```\n}
  end

  def responder_categories
    categories = {}
    Bitbot.configuration.responders.each do |responder|
      category = responder.category_name

      categories[category] ||= []
      (responder.command_help || []).each do |help|
        categories[category] << help_for_command(help)
      end
    end
    categories
  end

  def help_for_command(help)
    "#{sprintf('%-30s', help[:phrase])} - #{help[:description]}"
  end
end
