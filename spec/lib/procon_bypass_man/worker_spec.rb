require "spec_helper"

describe ProconBypassMan::Worker do
  describe '#work' do
    context 'エラーが起きない時' do
      let(:test_job) do
        Class.new do
          def self.perform(*); end
        end
      end

      it do
        expect { ProconBypassMan::Worker.new.work(job_class: test_job, args: [1]) }.not_to raise_error
      end
    end

    context 'エラーが起きる時' do
      include_context 'enable_job_queue_on_drb'

      before do
        allow(ProconBypassMan).to receive(:logger) { double(:logger).as_null_object }
        allow(ProconBypassMan::Background::JobQueue).to receive(:enable?) { true }
      end

      context 're_enqueue_if_failedがfalseなjob' do
        let(:test_job) do Class.new do
            def self.perform(*)
              raise RuntimeError, nil
            end
          end
        end

        it do
          expect { ProconBypassMan::Worker.new.work(job_class: test_job, args: []) }.not_to raise_error
          expect(ProconBypassMan::Background::JobQueue.size).to eq(0)
        end
      end

      context 're_enqueue_if_failedがtrueなjob' do
        let(:test_job) do Class.new(ProconBypassMan::BaseJob) do
            def self.perform(*)
              raise RuntimeError, nil
            end

            def self.re_enqueue_if_failed
              true
            end
          end
        end

        it do
          expect { ProconBypassMan::Worker.new.work(job_class: test_job, args: []) }.not_to raise_error
          expect(ProconBypassMan::Background::JobQueue.size).to eq(1)
        end
      end
    end
  end
end
