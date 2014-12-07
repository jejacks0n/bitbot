require 'bundler/setup'

require 'bitbot'
require 'fakeredis'

require 'coveralls'
Coveralls.wear!

Bitbot.configuration.redis_connection = Redis.new
