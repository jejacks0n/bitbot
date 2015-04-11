require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

# require "simplecov"
# SimpleCov.start

ENV["BITBOT_INCOMING_WEBHOOK_URL"] = "http://bitbot.slack.com/endpoint"
ENV["BITBOT_API_TOKEN"] = "_api_token_"
ENV["WIT_AI_TOKEN"] = "XXX"

require "fakeredis"
require "bitbot"

require "wit_ruby"

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |f| require f }
