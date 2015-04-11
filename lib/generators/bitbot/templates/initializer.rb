Bitbot.configure do |config|
  config.user_name = "bitbot"
  config.full_name = "Bit Bot"

  config.webhook_url = ENV["BITBOT_INCOMING_WEBHOOK_URL"]
  config.redis_connection = Redis.current ||= Redis.new(url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379")

  config.responders = Dir[File.expand_path("lib/bitbot/**/*_responder.rb", __FILE__)]

  config.listener :web do |listener|
    listener.token = ENV["BITBOT_OUTGOING_WEBHOOK_TOKEN"] || "token"

    listener.path = "/rack-bitbot-webhook" # this needs to match where you mount the webbook
  end

  # this will preload the responders, and may not be desirable in dev/test environments
  config.load_responders
end
