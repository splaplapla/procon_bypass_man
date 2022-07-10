require "spec_helper"

describe ProconBypassMan::Procon::PerformanceMeasurement::SpanTransferBuffer do
  describe '#push_and_run_block_if_buffer_over' do
    context 'buffer_over?がfalseのとき' do
      before do
        allow(described_class.instance).to receive(:buffer_over?) { false }
      end

      it do
        expect(described_class.instance).not_to receive(:clear)
        described_class.instance.push_and_run_block_if_buffer_over(nil) {}
      end
    end

    context 'buffer_over?がtrueのとき' do
      before do
        allow(described_class.instance).to receive(:buffer_over?) { true }
      end

      it do
        expect(described_class.instance).to receive(:clear)
        described_class.instance.push_and_run_block_if_buffer_over(nil) {}
      end
    end
  end
end
