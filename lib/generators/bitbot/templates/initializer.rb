Bitbot.configure do |config|
  config.user_name = "bitbot"
  config.full_name = "Bit Bot"

  config.webhook_url = ENV["BITBOT_INCOMING_WEBHOOK_URL"]
  config.api_token = ENV["BITBOT_API_TOKEN"]

  config.redis_connection = proc { Redis.current ||= Redis.new(url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379") }
  config.locales = Dir[Rails.root.join("config/locale/*.yml", __FILE__)]
  config.responders = Dir[Rails.root.join("lib/bitbot_responders/**/*_responder.rb", __FILE__)]

  config.load_responders # preload the responders -- may not be desirable in dev/test environments

  config.listener Bitbot::Listener::Web do |listener|
    listener.token = ENV["BITBOT_OUTGOING_WEBHOOK_TOKEN"] || "token"
    listener.path = "/rack-bitbot-webhook" # this needs to match where you mount the webbook in routes.rb
  end

  config.on_exception do |e, request|
    # You could log to your error tracking system or something.
    # Bitbot.log("#{e.class.name}: #{e.message} -- #{request.method} #{request.path}")
  end
end
