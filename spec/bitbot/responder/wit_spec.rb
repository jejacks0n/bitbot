require "spec_helper"

describe Bitbot::Responder::Wit do
  let(:described_class) { Class.new(Bitbot::Responder) { include Bitbot::Responder::Wit } }

  describe "DSL" do
    it "adds an intent method" do
      described_class.intent(:foo, "_route_", bar: "baz")
      expect(described_class.intents).to eq(foo: { route: "_route_", bar: "baz" } )
    end
  end

end
