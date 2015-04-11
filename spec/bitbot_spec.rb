require "spec_helper"

describe Bitbot do
  describe ".listener" do
    it "should be tested"
  end

  describe ".listen" do
    it "should be tested"
  end

  describe ".announce" do
    it "announces the json provided using the webhook" do
      expect(Bitbot::Webhook).to receive(:announce).with(foo: "bar")
      subject.announce(foo: "bar")
    end
  end

  describe ".log" do
    it "prints the message to STDOUT" do
      expect(STDOUT).to receive(:print).with("_message_\n")
      subject.log("_message_")
    end
  end
end
