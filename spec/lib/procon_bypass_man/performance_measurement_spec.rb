require "spec_helper"

describe ProconBypassMan::Procon::PerformanceMeasurement do
  context 'enable_procon_performance_measurement?がtreuのとき' do
    before do
      allow(ProconBypassMan.config).to receive(:enable_procon_performance_measurement?) { true }
    end

    it 'measureのタイミングがずるないとき' do
      described_class.measure { 1 }
      Timecop.freeze '2021-11-11 00:00:01' do
        described_class.measure { 1 }
      end
      collection = described_class.pop
      expect(collection.timestamp_key).to be_truthy
      expect(collection.measurements).to be_a(Array)
      expect(described_class.pop).to be_nil
    end

    it 'measureのタイミングがずれないとき' do
      Timecop.freeze '2021-11-11 00:00:01' do
        described_class.measure { 1 }
      end
      expect(described_class.pop).to be_nil
    end
  end

  context 'enable_procon_performance_measurement?がfalseのとき' do
    it do
      described_class.measure { 1 }
      Timecop.freeze '2021-11-11 00:00:01' do
        described_class.measure { 1 }
      end

      expect(described_class.pop).to be_nil
    end
  end
end
