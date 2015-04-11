require "spec_helper"

describe Bitbot::RestClient::Users do
  subject { described_class }
  let(:read) { double(read: %{{"foo":"bar"}}) }

  before do
    allow(subject).to receive(:open).and_return(read)
  end

  describe ".info" do
    it "returns user information" do
      expect(subject.info("@archer")).to eq("foo" => "bar")
      expect(subject).to have_received(:open).with("https://slack.com/api/users.info?user=@archer&token=_api_token_")
    end
  end
end
