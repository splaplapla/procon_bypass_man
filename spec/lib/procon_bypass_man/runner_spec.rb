require "spec_helper"

describe ProconBypassMan::Runner do
  describe 'signal handling' do
    it 'signalを受けてexitすること' do
      ProconBypassMan.config.verbose_bypass_log = false
      procon = double(:procon).as_null_object
      gadget = double(:gadget).as_null_object
      runner_pid = Kernel.fork { described_class.new(gadget: gadget, procon: procon).run }
      # signal trapが完了するまで適当にsleepする
      sleep 1

      Process.kill('TERM', runner_pid)
      result = Process.waitpid2(runner_pid)
      expect(result[1].exited?).to eq(true)
    end
  end
end
