require "spec_helper"

describe ProconBypassMan::Scheduler do
  let(:job_class) {
    Class.new do
      def self.perform_async; end
    end
  }

  describe '.register' do
    subject { described_class.register(schedule: ProconBypassMan::Scheduler::Schedule.new(klass: job_class, interval: 2)) }

    it do
      expect { subject }.to change { described_class.schedules.size }.by(1)
    end
  end

  describe ProconBypassMan::Scheduler::Schedule do
    describe '#past_interval?' do
      let(:schedule) { described_class.new(klass: job_class, interval: 2) }

      subject { schedule.past_interval? }

      before do
        Timecop.freeze '2021-11-11 00:00:00' do
          schedule
        end
      end

      context '時間が経過していない' do
        it do
          Timecop.freeze '2021-11-11 00:00:00' do
            is_expected.to eq(false)
          end
        end

        it do
          Timecop.freeze '2021-11-11 00:00:01' do
            is_expected.to eq(false)
          end
        end
      end

      context '時間が経過した' do
        it do
          Timecop.freeze '2021-11-11 00:00:03' do
            is_expected.to eq(true)
          end
        end
      end
    end

    describe '#enqueue' do
      let(:schedule) { described_class.new(klass: job_class, interval: 2) }

      subject { schedule.enqueue }

      it 'next_enqueue_atを更新すること' do
        Timecop.freeze '2021-11-11 00:00:00' do
          schedule.enqueue
        end
        base = schedule.next_enqueue_at.to_i
        Timecop.freeze '2021-11-11 00:00:03' do
          schedule.enqueue
          expect(schedule.next_enqueue_at.to_i - base).to eq(3)
        end
      end

      it 'be call perform_async' do
        expect(job_class).to receive(:perform_async)
        subject
      end
    end
  end
end
