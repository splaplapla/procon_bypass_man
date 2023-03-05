require "spec_helper"

describe ProconBypassMan::RemoteActionSender do
  before do
    allow(ProconBypassMan::RemoteAction::QueueOverProcess).to receive(:enable?) { true }
    ProconBypassMan::RemoteAction::QueueOverProcess.start!
  end

  after do
    ProconBypassMan::RemoteAction::QueueOverProcess.shutdown
  end

  describe '.execute' do
    let(:name) { "a" }
    let(:uuid) { "b" }
    let(:steps) { "c" }

    subject { described_class.execute(name: name, uuid: uuid, steps: steps, type: nil) }

    it do
      subject
      expect(ProconBypassMan::RemoteAction::QueueOverProcess.pop).not_to be_nil
    end
  end
end
