require "spec_helper"

describe Bitbot::Listener::Base do
  before do
    allow(Bitbot).to receive(:log)
  end

  describe ".type_name" do
    it "returns the shortened class name" do
      expect(described_class.type_name).to eq(:base)
    end
  end

  describe "#initialize" do
    it "can configure itself with a block" do
      subject = described_class.new { |l| l.token = "_token_" }
      expect(subject.instance_variable_get(:@token)).to eq("_token_")
    end

    it "warns if there was no token provided" do
      expect(Bitbot).to receive(:log).with("Warning, no outgoing slack token provided.")
      described_class.new
    end
  end

  describe "#listen" do
    it "raises an exception" do
      expect { subject.listen }.to raise_error(
        Bitbot::Error,
        "Expected subclass to implement the `listen` method."
      )
    end
  end
end
