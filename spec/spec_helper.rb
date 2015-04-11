require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

# require "simplecov"
# SimpleCov.start

require "fakeredis"
require "bitbot"

Bitbot.configuration.redis_connection = Redis.new
