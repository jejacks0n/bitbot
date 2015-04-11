require "spec_helper"

describe Bitbot::Listener::Web do
  before do
    allow(Bitbot).to receive(:log)
  end

  describe ".type_name" do
    it "returns the shortened class name" do
      expect(described_class.type_name).to eq(:web)
    end
  end

  describe "#initialize" do
    it "can configure itself with a block" do
      config = proc do |l|
        l.path = "_path_"
        l.port = "3000"
      end
      subject = described_class.new(&config)
      expect(subject.instance_variable_get(:@path)).to eq("_path_")
      expect(subject.instance_variable_get(:@port)).to eq("3000")
    end

    it "uses default values for unconfigured options" do
      subject = described_class.new
      expect(subject.instance_variable_get(:@path)).to eq("/")
      expect(subject.instance_variable_get(:@port)).to eq("9292")
    end
  end

  describe "#listen" do
    before do
      allow(Rack::Handler::WEBrick).to receive(:run)
    end

    it "starts up a rack server" do
      allow(Rack::Handler::WEBrick).to receive(:run).with(subject, Port: "9292").and_yield(double(stop: nil))
      expect(Bitbot).to receive(:log).with("Starting web listener at 127.0.0.1:9292")
      subject.listen
    end
  end

  describe "integration" do
    subject { described_class.new { |l| l.token = @token || ["_token_", "_second_token_"] } }
    let(:app) { Rack::MockRequest.new(subject) }
    let(:params) { { text: "foobar", user_name: "jejacks0n", token: "_token_" } }

    before do
      allow_any_instance_of(Bitbot::Router).to receive(:route_message).and_return(foo: "bar")
    end

    it "responds with a 204 if the request isn't verified" do
      response = app.get("/", params: params)
      expect(response.status).to eq(204) # not a post request

      response = app.put("/", params: params)
      expect(response.status).to eq(204) # not a post request

      response = app.post("/path", params: params)
      expect(response.status).to eq(204) # path is incorrect

      response = app.post("/", params: params.merge(text: nil))
      expect(response.status).to eq(204) # text isn't a string

      response = app.post("/", params: params.merge(user_name: "bitbot"))
      expect(response.status).to eq(204) # user_name is the same as the bot receiving the message

      response = app.post("/", params: params.merge(token: "token"))
      expect(response.status).to eq(204) # token isn't correct
    end

    it "renders a response if the params are verified" do
      response = app.post("/", params: params)

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(response.body).to eq(%{{"foo":"bar"}})
    end

    it "allows using alternate tokens" do
      response = app.post("/", params: params.merge(token: "_second_token_"))

      expect(response.status).to eq(200)
      expect(response.body).to eq(%{{"foo":"bar"}})
    end

    it "allows configuring only one token" do
      @token = "_single_token_"
      response = app.post("/", params: params.merge(token: "_single_token_"))

      expect(response.status).to eq(200)
      expect(response.body).to eq(%{{"foo":"bar"}})
    end

    it "renders a useful response on errors" do
      allow_any_instance_of(Bitbot::Router).to receive(:route_message).and_raise(StandardError, "_message_")
      expect(subject).to receive(:handle_exception).with(instance_of(Rack::Request), instance_of(StandardError))
      response = app.post("/", params: params)

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(response.body).to eq(%{{"text":"Oh-uh, we've had some issues: #<StandardError: _message_>"}})
    end

    it "doesn't render a response on errors if the request wasn't verified" do
      expect(subject).to receive(:verified_request).and_raise(StandardError)
      response = app.post("/", params: params)

      expect(response.status).to eq(204)
    end

    it "handles errors that are intended for flow/logic control" do
      allow_any_instance_of(Bitbot::Router).to receive(:route_message).and_raise(Bitbot::Response, "_response_message_")
      response = app.post("/", params: params)

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(response.body).to eq(%{{"text":"Uh-oh, _response_message_"}})
    end
  end
end
