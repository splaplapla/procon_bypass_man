require "spec_helper"

describe ProconBypassMan::RemoteActionReceiver do

  describe '.start!' do
    context 'not enable' do
      it do
        expect(described_class.start_with_foreground!).to eq(nil)
      end
    end

    context 'enable' do
      before do
        allow(ProconBypassMan.config).to receive(:enable_remote_action?) { true }
        allow(ProconBypassMan::RemoteAction::QueueOverProcess).to receive(:enable?) { true }
        ProconBypassMan::RemoteAction::QueueOverProcess.start!
      end

      after do
        ProconBypassMan::RemoteAction::QueueOverProcess.shutdown
      end

      it do
        ProconBypassMan::RemoteAction::QueueOverProcess.push(2)
        ProconBypassMan::RemoteAction::QueueOverProcess.push(false)
        expect(described_class).to receive(:receive).with(2)
        expect(described_class).to receive(:shutdown)
        expect { described_class.start_with_foreground! }.not_to raise_error
      end
    end
  end
end
