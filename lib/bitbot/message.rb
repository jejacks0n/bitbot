require "ostruct"

module Bitbot
  class Message < OpenStruct
    def initialize(val)
      val[:wit] = nil
      super
      @forced = false
    end

    def channel
      self["channel"] || self["channel_name"] || self["channel_id"]
    end

    def text=(val)
      self["text"] = val
      @text = nil
      @sanitized_text = nil
      self["text"]
    end

    def text
      @text ||= self["text"].gsub(/^(#{Bitbot.configuration.user_name}),?(\s+)/i, "")
    end

    def sanitized_text
      @sanitized_text ||= self["text"].gsub(/<mailto:(?:[^\|]+\|)?([^>]+)>/, '\1')
    end

    def raw_text
      self["text"]
    end

    def command?
      !!self["command"]
    end

    def forced?
      @forced
    end

    def force!
      @forced = true
      self
    end

    def to_json
      to_h.to_json
    end
  end
end
