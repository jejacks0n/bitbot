require "spec_helper"

describe Bitbot::Webhook do
  before do
    allow(Bitbot.configuration).to receive(:webhook_url).and_return("https://www.example.com:80/path")
  end

  describe "#announce" do
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

    it "logs that it was unable to announce if the webhook url is invalid" do
      expect(subject).to receive(:uri).and_raise(URI::InvalidURIError)
      expect(Bitbot).to receive(:log).with("Unable to announce, invalid webhook_url is present.")

      subject.announce(foo: "bar")
    end
  end
end
