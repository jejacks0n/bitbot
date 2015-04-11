require "spec_helper"

class ConfirmableResponder < Bitbot::Responder
  route :confirm, /^confirm/ do
    confirm("are you sure?", "bot absolutely") do
      respond_with(text: "Okay #{message.user_name}, thanks for confirming.")
    end
  end
end

describe ConfirmableResponder do
  let(:message) { Bitbot::Message.new(text: "confirm", user_name: "archer", channel: "foo") }
  let(:reject) { Bitbot::Message.new(text: "foo", user_name: "archer", channel: "foo") }
  let(:approve) { Bitbot::Message.new(text: "bot absolutely", user_name: "archer", channel: "foo") }
  let(:approve_other_channel) { Bitbot::Message.new(text: "bot absolutely", user_name: "archer", channel: "bar") }
  let(:approve_other_user) { Bitbot::Message.new(text: "bot absolutely", user_name: "lanakane", channel: "foo") }

  it "responds to the command" do
    expect(subject.class.responds_to?(message)).to be_truthy
  end

  it "allows canceling by saying anything other than what was expected" do
    response = subject.respond_to(message)
    expect(response[:text]).to eq(":warning: Whoa archer, are you sure?")

    response = subject.respond_to(reject)
    expect(response[:text]).to eq("Okay archer, nothing happened, moving on.")
  end

  it "allows continuing with the command my confirming" do
    response = subject.respond_to(message)
    expect(response[:text]).to eq(":warning: Whoa archer, are you sure?")

    response = subject.respond_to(approve)
    expect(response[:text]).to eq("Okay archer, thanks for confirming.")
  end

  it "does not confirm between channels" do
    response = subject.respond_to(message)
    expect(response[:text]).to eq(":warning: Whoa archer, are you sure?")

    expect { subject.respond_to(approve_other_channel) }.to raise_error(
      Bitbot::NoRouteError,
      "Unable to respond, no route found for message."
    )
    subject.respond_to(approve)
  end

  it "does not confirm between users" do
    response = subject.respond_to(message)
    expect(response[:text]).to eq(":warning: Whoa archer, are you sure?")

    expect { subject.respond_to(approve_other_user) }.to raise_error(
      Bitbot::NoRouteError,
      "Unable to respond, no route found for message."
    )
    subject.respond_to(approve)
  end
end
