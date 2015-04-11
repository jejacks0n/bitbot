root = File.expand_path("../../lib", __FILE__)
$:.unshift(root) unless $:.include?(root)

require "bitbot"

Bitbot.configure do |config|
  config.redis_connection = proc { Redis.current ||= Redis.new(url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379") }

  config.locales = Dir[File.expand_path("../../locale/*.yml", __FILE__)]
  config.responders = Dir[File.expand_path("../../lib/bitbot_responders/**/*_responder.rb", __FILE__)]
  config.load_responders

  config.listener Bitbot::Listener::Web do |listener|
    listener.token = ENV["BITBOT_OUTGOING_WEBHOOK_TOKEN"] || "token"
    listener.path = "/rack-bitbot-webhook"
  end

  config.on_exception do |e, request|
    Bitbot.log("#{e.class.name}: #{e.message} -- #{request.method} #{request.path}")
  end
end

# start the rack application with the web listener (useful within a config.ru file)
run Bitbot.listener(Bitbot::Listener::Web)
# start a rack server directly (useful for an executable file)
# Bitbot.listen(Bitbot::Listener::Web)
