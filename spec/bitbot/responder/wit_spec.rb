require "spec_helper"

describe Bitbot::Responder::Wit do
  let(:described_class) { Class.new(Bitbot::Responder) { include Bitbot::Responder::Wit } }
  let(:message) { Bitbot::Message.new(attrs) }
  let(:attrs) { { user_name: "archer", text: "lana. lana. LANA!", channel_name: "isis", channel_id: "42" } }
  before do
    described_class.routes = nil
    described_class.remove_message(message)
  end

  describe "DSL" do
    it "adds an intent method" do
      described_class.intent(:foo, "_route_", bar: "baz")
      expect(described_class.intents).to eq(foo: { route: "_route_", bar: "baz" })
      expect(described_class.instance_variable_get(:@wit)).to be_a(Wit::REST::Session)
    end
  end

  describe ".route_for" do
    it "doesn't break the existing routing logic" do
      route = described_class.route(:test, attrs[:text]) { }

      expect(described_class.route_for(message)).to eq(route)
    end

    it "adds the concept of wit to routing" do
      mock = double(intent: "_intent_", confidence: 0.9)
      allow_any_instance_of(Wit::REST::Session).to receive(:send_message).and_return(mock)

      route = described_class.route(:test, "XXX") { }
      described_class.intent("_intent_", :test)

      expect(described_class.route_for(message)).to eq(route)
    end

    it "doesn't route if the confidence isn't high enough" do
      mock = double(intent: "_intent_", confidence: 0.7)
      allow_any_instance_of(Wit::REST::Session).to receive(:send_message).and_return(mock)

      described_class.route(:test, "XXX") { }
      described_class.intent("_intent_", :test)

      expect(described_class.route_for(message)).to be_falsey
    end
  end

  describe "integration" do
    context "when there was no wit response" do
      before do
        message.wit = double(intent: "_non_intent_", confidence: 0.1)
        subject.message = message
      end

      it "passes entities defined into the route" do
        described_class.intent("_intent_", :foo)

        value = nil
        described_class.route(:test, /lana(.*)/) { |v| value = v }

        subject.respond_to(message)
        expect(value).to eq(". lana. LANA!")
      end
    end

    context "when wit responded" do
      before do
        entities = { "foo" => [{ "value" => "baz", "normals" => { "x" => 42, "y" => 666 } }] }
        message.wit = double(intent: "_intent_", confidence: 0.9, entities: entities)
        subject.message = message
      end

      it "passes entities defined into the route" do
        described_class.intent("_intent_", :test, entities: { foo: "bar" })

        value = nil
        described_class.route(:test, "XXX") { |v| value = v }
        subject.respond_to(message)

        expect(value).to eq("baz")
      end

      it "handles complex entity paths" do
        described_class.intent("_intent_", :test, entities: { foo: ->(e) { e["normals"]["x"] } })

        value = nil
        described_class.route(:test, "XXX") { |v| value = v }
        subject.respond_to(message)

        expect(value).to eq(42)
      end
    end
  end
end
