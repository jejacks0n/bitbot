# encoding: utf-8

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bitbot/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bitbot"
  s.version     = Bitbot::VERSION
  s.authors     = ["jejacks0n"]
  s.email       = ["jejacks0n@gmail.com"]
  s.homepage    = "http://github.com/jejacks0n/bitbot"
  s.summary     = "Bitbot: Slack interface with custom responders and Wit.ai support"
  s.description = "Write custom responders to integrate with slack for an admin or ops level command interface."
  s.license     = "MIT"
  s.files       = Dir["{lib}/**/*"] + ["MIT.LICENSE", "README.md"]

  s.required_ruby_version = "~> 2.4"
  s.add_dependency "rack"
  s.add_dependency "redis"
  s.add_dependency "activesupport" # TODO: move to remove this.
end
