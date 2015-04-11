require "spec_helper"

describe Bitbot::Message do
  subject { Bitbot::Message.new(json) }
  let(:json) { { command: "/command", text: "text", forced: true, forced?: true } }

  describe "text and raw text" do
    it "strips any bot names from the text" do
      subject.text = "bitbot is a secret spy"
      expect(subject.text).to eq("is a secret spy")
    end

    it "tracks its raw text" do
      subject.text = "bitbot likes it raw"
      expect(subject.raw_text).to eq("bitbot likes it raw")
    end
  end

  describe "handling commands" do
    it "knows when it has a command" do
      expect(subject.command?).to be_truthy
      subject.command = false
      expect(subject.command?).to be_falsey
    end
  end

  describe "forcing confirmations" do
    it "allows being forced" do
      expect(subject.forced?).to be_falsey
      subject.force!
      expect(subject.forced?).to be_truthy
    end
  end
end
