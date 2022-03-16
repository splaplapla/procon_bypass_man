require "spec_helper"

describe ProconBypassMan::QueueOverProcess do
  before(:each) do
    allow(ProconBypassMan.config).to receive(:enable_remote_macro?) { true }
  end

  after do
    ProconBypassMan::QueueOverProcess.shutdown
  end

  describe '.start!' do
    subject { described_class.start! }

    context 'when not enable' do
      it do
        allow(ProconBypassMan.config).to receive(:enable_remote_macro?) { false }
        expect(subject).to be_nil
      end
    end

    context 'when enable' do
      it do
        expect { subject }.not_to raise_error
      end

      it do
        expect(DRb).to receive(:start_service)
        subject
      end
    end
  end

  describe 'pop, push' do
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
