require "spec_helper"

describe Bitbot do
  describe ".listener" do
    it "instantiates the listener with the expected configuration" do
      expect(Bitbot.configuration).to receive(:listeners).and_return(web: config = proc {})
      expect(Bitbot::Listener::Web).to receive(:new) { |&block| expect(block).to be(config) }

      subject.listener(Bitbot::Listener::Web)
    end
  end

  describe ".listen" do
    it "starts listening using the listener provided" do
      mock = double(listen: nil)
      expect(subject).to receive(:listener).with(Bitbot::Listener::Web).and_return(mock)
      expect(mock).to receive(:listen)

      subject.listen(Bitbot::Listener::Web)
    end
  end

  describe ".announce" do
    it "announces the json provided using the webhook" do
      expect_any_instance_of(Bitbot::Webhook).to receive(:announce).with(foo: "bar")
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
