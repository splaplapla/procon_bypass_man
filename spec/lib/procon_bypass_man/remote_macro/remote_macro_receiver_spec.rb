require "spec_helper"

describe ProconBypassMan::RemoteMacroReceiver do
  require 'drb/drb'

  after do
    ProconBypassMan::QueueOverProcess.shutdown
  end

  describe '.start!' do
    context 'not enable' do
      it do
        expect(described_class.start_with_foreground!).to eq(nil)
      end
    end

    context 'enable' do
      before do
        allow(ProconBypassMan.config).to receive(:enable_remote_macro?) { true }
        ProconBypassMan::QueueOverProcess.start!
      end

      it do
        ProconBypassMan::QueueOverProcess.push(2)
        ProconBypassMan::QueueOverProcess.push(false)
        expect(described_class).to receive(:receive).with(2)
        expect(described_class).to receive(:shutdown)
        expect { described_class.start_with_foreground! }.not_to raise_error
      end
    end
  end
end
