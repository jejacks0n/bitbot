require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

# require "simplecov"
# SimpleCov.start

ENV["BITBOT_INCOMING_WEBHOOK_URL"] = "http://bitbot.slack.com/endpoint"
ENV["BITBOT_API_TOKEN"] = "_api_token_"

require "fakeredis"
require "bitbot"

Dir[File.expand_path('../support/*.rb', __FILE__)].each { |f| require f }
