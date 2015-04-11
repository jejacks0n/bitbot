require "bundler/setup"

require "bitbot"
require "fakeredis"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

Bitbot.configuration.redis_connection = Redis.new
