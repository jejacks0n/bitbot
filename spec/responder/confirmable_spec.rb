require "spec_helper"

describe Bitbot::Responder::Confirmable do
  let(:described_class) do
    Class.new(Bitbot::Responder) do
      include Bitbot::Responder::Redis
      include Bitbot::Responder::Confirmable
    end
  end
  let(:message) { Bitbot::Message.new(attrs) }
  let(:attrs) { { user_name: "archer", text: "lana. lana. LANA!", channel_name: "isis", channel_id: "42" } }

  describe ".awaiting_confirmation_for" do
    it "returns a message if one is awaiting confirmation" do
      described_class.store_message(message)

      expect(described_class.awaiting_confirmation_for(message)).to eq(message)
    end
  end

  describe "#confirm" do
    it "should be tested"
  end

  describe "#confirmation_message" do
    before do
      subject.message = message
    end

    it "returns the expected confirmation message" do
      text = "Please confirm with `YES`. You can say `no` or `cancel` to cancel."
      expect(subject.confirmation_message("are you certain???", "YES")).to eq(
        text: ":warning: Whoa archer, are you certain???",
        attachments: [{ fallback: text, text: text, color: "#FFBB00", mrkdwn_in: ["text"] }]
      )
    end
  end

  describe "#not_confirmed_message" do
    before do
      subject.message = message
    end

    it "returns the expected message" do
      expect(subject.not_confirmed_message).to eq(text: "Okay archer, nothing happened, moving on.")
    end
  end
end
