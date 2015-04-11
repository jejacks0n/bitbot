require "spec_helper"

describe Bitbot::Responder do
  let(:message) { Bitbot::Message.new(attrs) }
  let(:attrs) { { user_name: "archer", text: "lana. lana. LANA!", channel_name: "isis", channel_id: "42" } }

  it "should be tested"

  describe "redis connection" do
    it "can store and retrieve data from redis" do
      subject.store_message(message)
      expect(subject.retrieve_message(message).user_name).to eq("archer")
      subject.remove_message(message)
      expect(subject.retrieve_message(message)).to eq(nil)
    end

    it "raises an exception if there is no connection" do
      subject.instance_variable_set(:'@connection', nil)
      expect(Bitbot.configuration).to receive(:redis_connection).and_return(nil)
      expect { subject.connection }.to raise_error(Bitbot::NoRedisException)
    end
  end
end
