require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/class/subclasses"
require "active_support/core_ext/string/strip"
require "i18n"
require "json"
require "redis"

# core
require "bitbot/version"
require "bitbot/exceptions"
require "bitbot/configuration"
require "bitbot/message"
require "bitbot/router"
require "bitbot/responder"
require "bitbot/webhook"

# listeners
require "bitbot/listener/base"

# rest client
require "bitbot/rest_client"

# public api
module Bitbot
  def self.listener(klass = Bitbot::Listener::Web)
    klass.new(&Bitbot.configuration.listeners[klass.type_name])
  end

  def self.listen(klass = Bitbot::Listener::Web)
    listener(klass).listen
  end

  def self.announce(json)
    (@webhook ||= Webhook.new).announce(json)
  end

  def self.log(msg)
    STDOUT.print("Bitbot: #{msg}\n")
  end
end
