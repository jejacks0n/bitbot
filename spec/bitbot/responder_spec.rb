require "spec_helper"

describe Bitbot::Responder do
  let(:message) { Bitbot::Message.new(attrs) }
  let(:attrs) { { user_name: "archer", text: "lana. lana. LANA!", channel_name: "isis", channel_id: "42" } }
  before do
    described_class.routes = nil
    described_class.remove_message(message)
  end

  describe ".responds_to?" do
    it "checks for awaiting confirmation messages" do
      described_class.store_message(message)

      expect(described_class.responds_to?(message)).to be_truthy
    end

    it "routes by a direct string match" do
      described_class.route(:test, "lana. lana. LANA!") { }

      expect(described_class.responds_to?(message)).to be_truthy
    end

    it "routes by a regexp match" do
      described_class.route(:test, /lana/) { }

      expect(described_class.responds_to?(message)).to be_truthy
    end

    it "handles command messages" do
      message.command = "/foo"
      described_class.route(:test, "not a match", command: "/foo") { }

      expect(described_class.responds_to?(message)).to be_truthy
    end

    it "returns false if there's no route for the message" do
      expect(described_class.responds_to?(message)).to be_falsy
    end
  end

  describe "#respond_to" do
    it "responds when the message is a hash" do
      described_class.route(:test, attrs[:text]) { "_response_" }

      expect(subject.respond_to(attrs)).to eq("_response_")
    end

    it "responds when the message is an object" do
      described_class.route(:test, attrs[:text]) { "_response_" }

      expect(subject.respond_to(message)).to eq("_response_")
    end

    it "sets the message to an instance variable" do
      described_class.route(:test, attrs[:text]) { }

      subject.respond_to(message)
      expect(subject.message).to eq(message)
    end

    it "responds to a stored message if one matches" do
      described_class.store_message(message)
      described_class.route(:test, attrs[:text]) { "_stored_response_" }

      expect(subject.respond_to(attrs.merge(text: "lana?"))).to eq("_stored_response_")
    end

    it "raises an exception if no route was found" do
      expect { subject.respond_to(message) }.to raise_error(
        Bitbot::NoRouteError,
        "Unable to respond, no route found for message."
      )
    end
  end

  describe "integration" do
    describe "building responses" do
      it "allows responding with text" do
        described_class.route(:test, attrs[:text]) { respond_with("_text_") }

        res = subject.respond_to(message)
        expect(res).to eq(text: "_text_", parse: "full")
      end

      it "allows responding with options that include text" do
        described_class.route(:test, attrs[:text]) { respond_with(foo: "bar", text: "_text_") }

        res = subject.respond_to(message)
        expect(res).to eq(text: "_text_", foo: "bar", parse: "full")
      end

      it "allows responding with options and a block for text" do
        described_class.route(:test, attrs[:text]) { respond_with(foo: "bar") { "_text_" } }

        res = subject.respond_to(message)
        expect(res).to eq(text: "_text_", foo: "bar", parse: "full")
      end
    end

    describe "sending private messages" do
      before do
        allow(Bitbot).to receive(:announce)
      end

      it "direct messages the user who sent the message" do
        described_class.route(:test1, attrs[:text]) { private_message(foo: "bar") { "_text1_" } }
        described_class.route(:test2, "lana?") { direct_message(foo: "bar") { "_text2_" } }

        subject.respond_to(attrs)
        expect(Bitbot).to have_received(:announce).with(foo: "bar", text: "_text1_", channel: "@archer")

        subject.respond_to(attrs.merge(text: "lana?"))
        expect(Bitbot).to have_received(:announce).with(foo: "bar", text: "_text2_", channel: "@archer")
      end
    end

    describe "announcing" do
      before do
        allow(Bitbot).to receive(:announce)
      end

      it "can announce multiple messages into the channel where the original message was sent" do
        described_class.route(:test, attrs[:text]) { announce(foo: "bar") { "_text_" } }

        subject.respond_to(message)
        expect(Bitbot).to have_received(:announce).with(foo: "bar", text: "_text_", channel: "#isis")
      end
    end

    describe "delaying responses" do
      before do
        allow(Bitbot).to receive(:announce)
        allow(Thread).to receive(:new).and_yield
        allow(subject).to receive(:sleep).and_return(nil)
      end

      it "can delay a response (typically for announcing something later)" do
        described_class.route(:test, attrs[:text]) { delay(20) { announce("_text_") } }

        subject.respond_to(message)
        expect(subject).to have_received(:sleep).with(20)
        expect(Bitbot).to have_received(:announce).with(text: "_text_", channel: "#isis")
      end
    end

    describe "processing arguments" do
      before do
        described_class.route(:test, /lana\.\s+([^\s]+)\s+([^\s]+)/) { |match1, match2| "#{match1} - #{match2}" }
      end

      it "can pull out arguments from a regex and pass them to the block" do
        res = subject.respond_to(message)
        expect(res).to eq("lana. - LANA!")

        res = subject.respond_to(attrs.merge(text: "lana. LANNNNA! oh."))
        expect(res).to eq("LANNNNA! - oh.")
      end

      it "handles arguments when using stored messages" do
        described_class.store_message(message)

        res = subject.respond_to(attrs.merge(text: "lana. LANNNNA! oh."))
        expect(res).to eq("lana. - LANA!")
      end
    end
  end
end
