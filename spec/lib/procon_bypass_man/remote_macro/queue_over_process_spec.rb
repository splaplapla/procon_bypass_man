require "spec_helper"

describe ProconBypassMan::RemoteAction::QueueOverProcess do
  describe '.start!' do
    subject { ProconBypassMan::RemoteAction::QueueOverProcess.start! }

    context 'when not enable' do
      it do
        allow(ProconBypassMan.config).to receive(:enable_remote_action?) { false }
        expect { subject }.not_to change { Thread.list.size }
      end
    end

    context 'when enable' do
      before(:each) do
        allow(ProconBypassMan.config).to receive(:enable_remote_action?) { true }
      end

      it do
        expect { subject }.not_to raise_error
        ProconBypassMan::RemoteAction::QueueOverProcess.shutdown
      end
    end
  end

  describe 'pop, push' do
    before do
      allow(ProconBypassMan::RemoteAction::QueueOverProcess).to receive(:enable?) { true }
      ProconBypassMan::RemoteAction::QueueOverProcess.start!
    end

    after do
      ProconBypassMan::RemoteAction::QueueOverProcess.shutdown
    end

    before do
      require 'drb/drb'
      described_class.clear
    end

    it do
      described_class.push "a"
      expect(described_class.pop).to eq("a")
    end
  end
end
