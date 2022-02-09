require "spec_helper"

describe ProconBypassMan::QueueOverProcess do
  describe '.start!' do
    subject { described_class.start! }
    it do
      expect { subject }.not_to raise_error
    end

    context 'when enable ws' do
      before do
        allow(ProconBypassMan.config).to receive(:enable_ws?) { true }
      end

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
      allow(ProconBypassMan.config).to receive(:enable_ws?) { true }
      described_class.start!
      described_class.drb.clear
    end

    it do
      described_class.push "a"
      expect(described_class.pop).to eq("a")
    end
  end
end
