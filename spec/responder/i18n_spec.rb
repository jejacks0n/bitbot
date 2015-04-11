require "spec_helper"

describe Bitbot::Responder::I18n do
  let(:described_class) { Class.new(Bitbot::Responder) { include Bitbot::Responder::I18n } }

  describe "#t" do
    it "translates a string" do
      expect(subject.send(:t, "foo")).to eq("translation missing: en.foo")
    end
  end
end
