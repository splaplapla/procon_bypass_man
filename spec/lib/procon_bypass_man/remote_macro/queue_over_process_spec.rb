require "spec_helper"

describe ProconBypassMan::QueueOverProcess do
  describe '.start!' do
    subject { ProconBypassMan::QueueOverProcess.start! }

    context 'when not enable' do
      it do
        allow(ProconBypassMan.config).to receive(:enable_remote_macro?) { false }
        expect(subject).to be_nil
      end
    end

    context 'when enable' do
      before(:each) do
        allow(ProconBypassMan.config).to receive(:enable_remote_macro?) { true }
      end

      after(:each) do
        ProconBypassMan::QueueOverProcess.shutdown
      end

      it do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe 'pop, push' do
    before(:each) do
      allow(ProconBypassMan.config).to receive(:enable_remote_macro?) { true }
      ProconBypassMan::QueueOverProcess.start!
    end

    after(:each) do
      ProconBypassMan::QueueOverProcess.shutdown
    end

    before do
      require 'drb/drb'
      described_class.drb.clear
    end

    it do
      described_class.push "a"
      expect(described_class.pop).to eq("a")
    end
  end
end
