require "spec_helper"

describe Bitbot::Router do
  let(:responder1) { double(new: instance ||= double(respond_to: nil), responds_to?: false) }
  let(:responder2) { double(new: instance ||= double(respond_to: nil), responds_to?: false) }
  let(:message) { Bitbot::Message.new(text: "foo", user_name: "archer") }

  it "routes messages to responders who say they handle it" do
    allow(subject).to receive(:responders).and_return([responder1, responder2])

    expect(responder2).to receive(:responds_to?).once.with(message).and_return(true)
    expect(responder2.new).to receive(:respond_to).once.with(message).and_return(foo: "bar")

    expect(subject.route_message(message)).to eq(foo: "bar")

    expect(responder1).to receive(:responds_to?).with(message).and_return(true)
    expect(responder1.new).to receive(:respond_to).with(message).and_return(bar: "baz")

    expect(subject.route_message(message)).to eq(bar: "baz")
  end

  it "raises an exception if no responders want to respond" do
    expect { subject.route_message(message) }.to raise_error(
      Bitbot::NoResponderException,
      "No route found"
    )
  end
end
