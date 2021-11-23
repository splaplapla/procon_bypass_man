require "spec_helper"

describe ProconBypassMan::BypassCommand do
  it 'signalを受けてexitすること' do
    ProconBypassMan.config.verbose_bypass_log = false
    procon = double(:procon).as_null_object
    gadget = double(:gadget).as_null_object
    command_pid = Kernel.fork { described_class.new(procon: procon, gadget: gadget).execute }
    # signal trapが完了するまで適当にsleepする
    sleep 1

    Process.kill('TERM', command_pid)
    result = Process.waitpid2(command_pid)
    expect(result[1].exited?).to eq(true)
  end
end
