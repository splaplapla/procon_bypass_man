require "spec_helper"

describe ProconBypassMan::Background::WorkerProcess do
  before do
    ProconBypassMan.config.logger = Logger.new($stderr)
  end

  it 'シグナルを受け取ったら終了すること' do
    worker_pid = Kernel.fork {
      described_class.run
    }
    sleep 0.2
    Process.kill('TERM', worker_pid)
    result = Process.waitpid2(worker_pid)
    expect(result[2].exited?).to eq(true)
  end

  describe 'ジョブの実行' do
    include_context 'enable_job_queue_on_drb'

    # プロセスを超えてデシリアライズができるよにclassキーワードで定義する
    class TestJobClass
      def self.perform
        puts 'hai'
      end
    end

    it '処理すること' do
      ProconBypassMan::Background::JobQueue.push({
        reporter_class: TestJobClass.to_s,
      })
      worker_pid = Kernel.fork do
        DRb.start_service if defined?(DRb)
        described_class.new.run # .runだとstubしているので
      end

      sleep(0.2)

      expect(ProconBypassMan::Background::JobQueue.size).to eq(0)
      Process.kill('TERM', worker_pid)
      result = Process.waitpid2(worker_pid)
      expect(result[1].exited?).to eq(true)
    end
  end
end
