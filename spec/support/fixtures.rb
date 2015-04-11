module FixtureHelpers
  def fixture(path)
    File.expand_path("../fixtures/#{path}", __FILE__)
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers
end
