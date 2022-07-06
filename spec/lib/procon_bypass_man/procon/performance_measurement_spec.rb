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
      collection = described_class.pop_measurement_collection
      expect(collection.timestamp_key).to be_truthy
      expect(collection.measurements).to be_a(Array)
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

    subject { described_class.summarize(measurements: measurements) }

    context '値があるとき' do
      let(:measurements) do
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
      let(:measurements) { [] }

      it { expect(subject.time_taken_p50).to eq(0) }
      it { expect(subject.time_taken_p95).to eq(0) }
      it { expect(subject.time_taken_p99).to eq(0) }
      it { expect(subject.time_taken_max).to eq(0) }
      it { expect(subject.read_error_count).to eq(0) }
      it { expect(subject.write_error_count).to eq(0) }
    end
  end
end
