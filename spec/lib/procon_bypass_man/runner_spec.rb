require "spec_helper"

describe ProconBypassMan::Runner do
  let(:binary) { [data].pack("H*") }
  let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

  describe 'signal handling' do
    it 'signalを受けてexitすること' do
      ProconBypassMan.config.verbose_bypass_log = false
      procon = StringIO.new(binary)
      gadget = double(:gadget).as_null_object
      runner_pid = Kernel.fork do
        begin
         described_class.new(gadget: gadget, procon: procon).run
        rescue ProconBypassMan::GracefulShutdown
          # no-op
        rescue => e
          ProconBypassMan.logger.error e
        end
      end
      # signal trapが完了するまで適当にsleepする
      sleep 1

      Process.kill('TERM', runner_pid)
      result = Process.waitpid2(runner_pid)
      expect(result[1].exited?).to eq(true)
    end
  end
end
