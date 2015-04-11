require "spec_helper"

describe Bitbot::Webhook do
  subject { Bitbot::Webhook }
  before do
    allow(Bitbot.configuration).to receive(:webhook_url).and_return("https://www.example.com:80/path")
  end

  describe "announcing content" do
    it "sends an http request" do
      expect(Net::HTTP).to receive(:new).with("www.example.com", 80).and_call_original
      expect(Net::HTTP::Post).to receive(:new).with("/path").and_call_original
      expect_any_instance_of(Net::HTTP).to receive(:request)
      expect_any_instance_of(Net::HTTP::Post).to receive(:set_form_data).
        with(payload: '{"foo":"bar","parse":"full","user_name":"bitbot"}')

      subject.announce(foo: "bar")
    end
  end
end
