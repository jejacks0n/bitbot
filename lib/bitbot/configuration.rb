module Bitbot
  class Configuration
    cattr_accessor :user_name, :full_name, :webhook_url, :api_token, :redis_connection, :whitelist_groups

    @@user_name = "bitbot"
    @@full_name = "Bit Bot"

    @@webhook_url = ENV["BITBOT_INCOMING_WEBHOOK_URL"]
    @@api_token = ENV["BITBOT_API_TOKEN"]

    @@redis_connection = nil # provide your own redis connection (eg. Redis.current) / can be a proc.

    # locales

    def self.locales=(files)
      I18n.enforce_available_locales = false # todo: this seems bad?
      I18n.load_path += files.is_a?(Array) ? files : [files]
      I18n.default_locale = :en
    end

    # responders

    cattr_accessor :responders
    @@responders = []
    @@responder_files = Dir[File.expand_path("../default_responders/*_responder.rb", __FILE__)]

    def self.responders=(files)
      @@responder_files += files.is_a?(Array) ? files : [files]
    end

    def self.load_responders
      Bitbot.log("Loading responders...")
      @@responder_files.each do |file|
        load(file)
        Bitbot.log("  loading #{Pathname.new(file).basename}")
      end
      @@responders = Bitbot::Responder.descendants.uniq
    end

    # exception handling

    def self.on_exception(&block)
      @exception_handler = block
    end

    def self.handle_exception(e, req)
      return unless @exception_handler
      @exception_handler.call(e, req)
    end

    # listeners

    cattr_accessor :listeners
    @@listeners = {}

    def self.listener(type = Bitbot::Listener::Web, &block)
      @@listeners[type.type_name] = block
    end

    # whitelist

    # By default, any responder without a specified group can use
    # all commands/responder routes.

    # By adding a group to a responder, i.e.
    # `group :moderation`
    # the bot should check a whitelist of to verify the channel name
    # matches the list of channels in the group's list (taken from
    # Bitbot configuration).

    cattr_accessor :whitelist_groups, :blacklist_groups

    # Hash of (group => channel name(s)) pairs
    # ex. { moderation: ['channel1', 'channel2'] }

    @@whitelist_groups = {
      support: [:friends].freeze,
      moderation: [:moderation].freeze
    }

    @@blacklist_groups = {
      support: [],
      moderation: []
    }

  end

  mattr_accessor :configuration
  @@configuration = Bitbot::Configuration

  def self.configure
    yield @@configuration
    Bitbot.log("No listeners configured.") if @@configuration.listeners.empty?
  end
end
