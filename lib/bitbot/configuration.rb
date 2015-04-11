module Bitbot
  class Configuration
    cattr_accessor :user_name, :full_name, :webhook_url, :redis_connection

    @@user_name = "bitbot"
    @@full_name = "Bit Bot"

    @@webhook_url = ENV["BITBOT_WEBHOOK_URL"]
    @@redis_connection = nil # provide your own redis connection (eg. Redis.current) / can be a proc.

    # locales

    def self.locales=(files)
      I18n.enforce_available_locales = false # todo: this seems bad?
      I18n.load_path += files
      I18n.default_locale = :en
    end

    # responders

    cattr_accessor :responders
    @@responders = []
    @@responder_files = Dir[File.expand_path("../default_responders/*_responder.rb", __FILE__)]

    def self.responders=(files)
      @@responder_files += files
    end

    def self.load_responders
      puts "Loading Responders..."
      @@responder_files.each do |file|
        load(file)
        puts "  loading #{Pathname.new(file).basename}"
      end
      @@responders = Responder.descendants
    end

    # listeners

    cattr_accessor :listeners
    @@listeners = {}

    def self.listener(type = Bitbot::Listener::Web, &block)
      @@listeners[type.type_name] = block
    end
  end

  mattr_accessor :configuration
  @@configuration = Configuration

  def self.configure
    yield @@configuration
  end
end
