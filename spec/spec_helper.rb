require 'bundler/setup'

require 'bitbot'
require 'coveralls'
Coveralls.wear!

Bitbot.configuration.redis_connection = Redis.new
