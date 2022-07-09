require "spec_helper"

describe ProconBypassMan::Procon::PerformanceMeasurement do
  context 'enable_procon_performance_measurement?がtrueのとき' do
    before do
      allow(ProconBypassMan.config).to receive(:enable_procon_performance_measurement?) { true }
      allow(ProconBypassMan::Procon::PerformanceMeasurement::SpanTransferBuffer.instance).to receive(:buffer_over?) { true }
      ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.start!
    end

    after do
      ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.shutdown
    end

    it 'measureのタイミングがずるないとき' do
      described_class.measure { 1 }
      # TODO job inline perfomeする
      Timecop.freeze '2021-11-11 00:00:01' do
        described_class.measure { 1 }
      end
      collection = described_class.pop_measurement_collection
      expect(collection.timestamp_key).to be_truthy
      expect(collection.spans).to be_a(Array)
      expect(described_class.pop_measurement_collection).to be_nil
    end

    it 'measureのタイミングがずれないとき' do
      Timecop.freeze '2021-11-11 00:00:01' do
        described_class.measure { 1 }
      end
      expect(described_class.pop_measurement_collection).to be_nil
    end
  end

  context 'enable_procon_performance_measurement?がfalseのとき' do
    it do
      described_class.measure { 1 }
      Timecop.freeze '2021-11-11 00:00:01' do
        described_class.measure { 1 }
      end

      expect(described_class.pop_measurement_collection).to be_nil
    end
  end

  describe '.summarize' do
    let(:measurement_class) { Struct.new(:time_taken, :read_error_count, :write_error_count) }

    subject { described_class.summarize(spans: spans) }

    context '値があるとき' do
      let(:spans) do
        [ measurement_class.new(1, 1, 2),
          measurement_class.new(4, 1, 2),
          measurement_class.new(2, 1, 2),
          measurement_class.new(3, 1, 2),
        ]
      end

      it { expect(subject.time_taken_p50).to eq(2.5) }
      it { expect(subject.time_taken_p95).to eq(3.849) }
      it { expect(subject.time_taken_p99).to eq(3.969) }
      it { expect(subject.time_taken_max).to eq(4) }
      it { expect(subject.read_error_count).to eq(4) }
      it { expect(subject.write_error_count).to eq(8) }
    end

    context '空配列のとき' do
      let(:spans) { [] }

      it { expect(subject.time_taken_p50).to eq(0) }
      it { expect(subject.time_taken_p95).to eq(0) }
      it { expect(subject.time_taken_p99).to eq(0) }
      it { expect(subject.time_taken_max).to eq(0) }
      it { expect(subject.read_error_count).to eq(0) }
      it { expect(subject.write_error_count).to eq(0) }
    end
  end
end
