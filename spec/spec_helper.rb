require 'rspec'
require 'bitbot'
require 'fakeredis'

Bitbot.configuration.redis_connection = Redis.new
