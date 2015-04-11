$:.push File.expand_path("../lib", __FILE__)
require "bitbot/version"

Gem::Specification.new do |s|
  s.name        = "bitbot"
  s.version     = Bitbot::VERSION
  s.authors     = ["jejacks0n"]
  s.email       = ["info@modeset.com"]
  s.summary     = "Bitbot: Slack interface with custom responders and Wit.ai support"

  s.files       = Dir["{lib}/**/*"] + ["README.md", "MIT.LICENSE"]
  s.test_files  = Dir["{spec}/**/*"]

  s.add_dependency "activesupport"
  s.add_dependency "rack"
  s.add_dependency "redis"
end
