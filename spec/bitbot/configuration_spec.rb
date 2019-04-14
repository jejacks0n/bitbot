require "spec_helper"

describe Bitbot::Configuration do
  subject { Bitbot.configuration }
  before do
    allow(Bitbot).to receive(:log)
  end

  it "allows adding locale files" do
    subject.locales = fixture("en.yml")
    subject.locales = [fixture("es.yml"), fixture("dk.yml")]

    expect(I18n.load_path).to include(fixture("en.yml"))
    expect(I18n.load_path).to include(fixture("es.yml"))
    expect(I18n.load_path).to include(fixture("dk.yml"))
  end

  it "allows adding and loading responders" do
    subject.responders = fixture("test_responder.rb")
    expect(Bitbot::Responder.descendants.map(&:to_s)).to_not include("TestResponder")

    subject.load_responders
    expect(Bitbot::Responder.descendants.map(&:to_s)).to include("TestResponder")
    expect(Bitbot).to have_received(:log).with("Loading responders...")
    expect(Bitbot).to have_received(:log).with("  loading help_responder.rb")
    expect(Bitbot).to have_received(:log).with("  loading test_responder.rb")
  end

  it "allows providing an exception handler" do
    e = nil
    req = nil
    subject.on_exception do |_e, _req|
      e = _e
      req = _req
    end

    subject.handle_exception("_e_", "_req_")
    expect(e).to eq("_e_")
    expect(req).to eq("_req_")
  end

  it "allows registering new listeners" do
    listener = Class.new(Bitbot::Listener::Base) do
      def self.type_name
        :custom_type
      end
    end

    subject.listener(listener, &(config = proc { }))
    expect(subject.listeners[:custom_type]).to eq(config)
  end

  it "allows configuration using a block" do
    Bitbot.configure do |config|
      config.full_name = "Bits to the Bot"
    end
  end
end
