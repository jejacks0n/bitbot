root = File.expand_path('../../lib', __FILE__)
$:.unshift(root) unless $:.include?(root)

require 'bitbot'

Bitbot.configure do |config|
  config.user_name = 'bitbot'
  config.full_name = 'Bit Bot'

  config.webhook_url = ENV['BITBOT_INCOMING_WEBHOOK_URL']
  config.redis_connection = Redis.new(url: ENV['REDIS_URL'] || 'redis://127.0.0.1:6379')

  config.locales = Dir[File.expand_path('../../locale/*.yml', __FILE__)]
  config.responders = Dir[File.expand_path('../../responders/**/*_responder.rb', __FILE__)]

  config.listener Bitbot::Listener::Web do |listener|
    listener.token = ENV['BITBOT_OUTGOING_WEBHOOK_TOKEN'] || 'token'

    listener.port = 3000
    listener.path = '/rack-bitbot-webhook'
  end

  # this will preload the responders
  config.load_responders
end

# start the rack application with the web listener (used within a rackup file)
run Bitbot.listener(Bitbot::Listener::Web)
# start a rack server directly (useful for an executable file)
# Bitbot.listen(Bitbot::Listener::Web)
