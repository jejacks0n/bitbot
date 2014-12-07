require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/class/subclasses'
require 'active_support/core_ext/string/strip'
require 'active_support/core_ext/string/inflections'

require 'i18n'
require 'json'

require 'bitbot/version'
require 'bitbot/configuration'
require 'bitbot/message'
require 'bitbot/router'
require 'bitbot/responder'
require 'bitbot/webhook'

require 'bitbot/rest_client/users'

I18n.enforce_available_locales = false

module Bitbot
  class BitbotException < Exception; end
  class BadRequestException < BitbotException; end
  class NoRouteException < BitbotException; end
  class NoResponderException < BitbotException; end
  class NoRedisException < BitbotException; end
  class Response < BitbotException; end

  module Listener
    autoload :Web, 'bitbot/listener/web'
  end

  def self.listener(type = :web)
    "Bitbot::Listener::#{type.to_s.camelize}".constantize.new(&Configuration.listeners[type])
  end

  def self.listen(type = :web)
    listener(type).listen
  end

  def self.announce(json)
    Webhook.announce(json)
  end

end

