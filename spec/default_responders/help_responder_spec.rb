require 'spec_helper'
require_relative '../../lib/bitbot/default_responders/help_responder'

class MockResponder < HelpResponder
  category 'Other'
  help 'foo', description: 'Describes the command'
end

describe HelpResponder do
  let(:message) { Bitbot::Message.new(text: text, user_name: 'archer') }

  describe 'asking for help' do
    let(:text) { 'help me' }
    before do
      allow(Bitbot::Webhook).to receive(:announce) { |json| @json = json }
      allow(Bitbot.configuration).to receive(:responders).and_return([HelpResponder, MockResponder])
    end

    it 'responds to the command' do
      expect(subject.class.responds_to?(message)).to be_truthy
    end

    it 'displays that it sent a private message' do
      response = subject.respond_to(message)
      expect(response[:text]).to eq('Providing help for archer in Private Message.')
    end

    it 'sends a private message' do
      subject.respond_to(message)
      expect(Bitbot::Webhook).to have_received(:announce).once
      expect(@json[:text]).to eq('Hello archer, here\'s what I can do.')
      expect(@json[:attachments][0][:text]).to eq <<-MSG.strip_heredoc
      ```
      General:
        help                           - You're looking at it
      Other:
        foo                            - Describes the command
      ```
      MSG
    end

  end
end
