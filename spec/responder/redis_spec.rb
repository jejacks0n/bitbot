require "spec_helper"

describe Bitbot::Responder::Redis do
  let(:described_class) { Class.new(Bitbot::Responder) { include Bitbot::Responder::Redis } }
  let(:message) { Bitbot::Message.new(attrs) }
  let(:attrs) { { user_name: "archer", text: "lana. lana. LANA!", channel_name: "isis", channel_id: "42" } }


  describe "#connection" do
    it "gets the connection from the configuration" do
      connection = Bitbot.configuration.redis_connection
      expect(subject.connection).to eq(connection)
    end

    it "handles when the connection is a proc (in case it needs to be set later)" do
      expect(Bitbot.configuration).to receive(:redis_connection).and_return(proc { "_connection_" })
      expect(subject.connection).to eq("_connection_")
    end

    it "raises an exception if there is no connection" do
      expect(Bitbot.configuration).to receive(:redis_connection).and_return(nil)
      expect { subject.connection }.to raise_error(
        Bitbot::NoRedisError
      )
    end
  end

  describe "#store_message" do
    before do
      subject.message = message
    end

    it "stores the message in redis" do
      expect(subject.connection).to receive(:set).with("bitbot:archer:isis:42:", subject.message.to_json)

      subject.store_message
    end
  end

  describe "#retrieve_message" do
    before do
      subject.message = message
    end

    it "retrieves the message from redis" do
      expect(subject.connection).to receive(:get).with("bitbot:archer:isis:42:")

      subject.retrieve_message
    end
  end

  describe "integration" do
    describe "class level" do
      subject { described_class }

      it "can store and retrieve data from redis" do
        expect(subject.key_for_redis(message)).to eq("bitbot:archer:isis:42:")
        subject.store_message(message)
        expect(subject.retrieve_message(message).user_name).to eq("archer")
        subject.remove_message(message)
        expect(subject.retrieve_message(message)).to eq(nil)
      end
    end

    describe "instance level" do
      before do
        subject.message = message
      end

      it "can store and retrieve data from redis" do
        subject.store_message
        expect(subject.retrieve_message.user_name).to eq("archer")
        subject.remove_message
        expect(subject.retrieve_message).to eq(nil)
      end
    end
  end
end
