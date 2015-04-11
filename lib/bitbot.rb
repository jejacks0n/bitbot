require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/class/subclasses"
require "active_support/core_ext/string/strip"
require "active_support/core_ext/string/inflections"

require "i18n"
require "json"

require "bitbot/version"
require "bitbot/exceptions"
require "bitbot/configuration"
require "bitbot/message"
require "bitbot/router"
require "bitbot/responder"
require "bitbot/webhook"
require "bitbot/listener/base"

require "bitbot/rest_client/users"

I18n.enforce_available_locales = false

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
    STDOUT.print("#{msg}\n")
  end
end
