require "spec_helper"

describe Bitbot::Message do
  subject { Bitbot::Message.new(json) }
  let(:json) { @json || { command: "/command", text: "text", forced: true, forced?: true } }

  describe "#channel" do
    it "does it's best to return a channel identifier" do
      subject.channel_id = "_channel_id_"
      subject.channel_name = "_channel_name_"
      subject.channel = "_channel_"

      expect(subject.channel).to eq("_channel_")
      subject.channel = nil
      expect(subject.channel).to eq("_channel_name_")
      subject.channel_name = nil
      expect(subject.channel).to eq("_channel_id_")
      subject.channel_id = nil
      expect(subject.channel).to eq(nil)
    end
  end

  describe "#text" do
    it "strips any bot names from the text" do
      subject.text = "bitbot is a secret spy"
      expect(subject.text).to eq("is a secret spy")

      subject.text = "bitbot,   what do you spy?"
      expect(subject.text).to eq("what do you spy?")
    end
  end

  describe "#sanitized_text" do
    it "returns sanitized text" do
      subject.text = "<mailto:foo@bar.com|foo@bar.com>"
      expect(subject.sanitized_text).to eq("foo@bar.com")
      subject.text = "new text <mailto:foo@bar.com|foo@bar.com:>"
      expect(subject.sanitized_text).to eq("new text foo@bar.com:")
    end
  end

  describe "#raw_text" do
    it "tracks its raw text" do
      subject.text = "bitbot likes it raw"
      expect(subject.raw_text).to eq("bitbot likes it raw")
    end
  end

  describe "#command?" do
    it "knows when it has a command" do
      expect(subject.command?).to be_truthy
      subject.command = false
      expect(subject.command?).to be_falsey
    end
  end

  describe "#force" do
    it "allows being forced for confirmation" do
      expect(subject.forced?).to be_falsey
      subject.force!
      expect(subject.forced?).to be_truthy
    end
  end

  describe "#to_json" do
    it "returns the expected json" do
      expect(subject.to_json).to eq(%{{"command":"/command","text":"text","forced":true,"forced?":true,"wit":null}})
    end
  end
end
