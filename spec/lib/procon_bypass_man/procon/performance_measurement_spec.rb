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

    it 'measureのタイミングがずれるとき' do
      Timecop.freeze '2021-11-11 00:00:01' do
        BackgroundJobInlinePerform.run do
          described_class.measure { 1 }
        end
      end
      BackgroundJobInlinePerform.run do
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
    let(:span_class) { Struct.new(:time_taken, :read_error_count, :write_error_count, :succeed, :interval_from_previous_succeed, :write_time, :read_time, :gc_count, ) }

    subject { described_class.summarize(spans: spans) }

    context '値があるとき' do
      let(:spans) do
        [ span_class.new(1, 1, 2, true, 1, 0.2, 0.2, 2),
          span_class.new(4, 1, 2, true, 2, 0.1, 0.1, 1),
          span_class.new(2, 1, 2, true, 3, 0.1, 0.1 , 1),
          span_class.new(3, 1, 2, false, 3, 0.1, 0.1, 2),
        ]
      end

      it { expect(subject.time_taken_p50).to eq(2.0) }
      it { expect(subject.time_taken_p95).to eq(3.8) }
      it { expect(subject.time_taken_p99).to eq(3.96) }
      it { expect(subject.time_taken_max).to eq(4) }
      it { expect(subject.read_error_count).to eq(4) }
      it { expect(subject.write_error_count).to eq(8) }
      it { expect(subject.succeed_rate).to eq(3 / 4.0) }
      it { expect(subject.interval_from_previous_succeed_max).to eq(3) }
      it { expect(subject.interval_from_previous_succeed_p50).to eq(2.0) }
      it { expect(subject.write_time_max).to eq(0.2) }
      it { expect(subject.write_time_p50).to eq(0.1) }
      it { expect(subject.gc_count).to eq(6) }
    end

    context '空配列のとき' do
      let(:spans) { [] }

      it { expect(subject.time_taken_p50).to eq(0) }
      it { expect(subject.time_taken_p95).to eq(0) }
      it { expect(subject.time_taken_p99).to eq(0) }
      it { expect(subject.time_taken_max).to eq(0) }
      it { expect(subject.read_error_count).to eq(0) }
      it { expect(subject.write_error_count).to eq(0) }
      it { expect(subject.interval_from_previous_succeed_max).to eq(0) }
      it { expect(subject.interval_from_previous_succeed_p50).to eq(0) }
      it { expect(subject.write_time_max).to eq(0) }
      it { expect(subject.write_time_p50).to eq(0) }
      it { expect(subject.gc_count).to eq(0) }
    end
  end
end
