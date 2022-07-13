require "spec_helper"

describe ProconBypassMan::BypassCommand do
  let(:binary) { [data].pack("H*") }
  let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

  it 'signalを受けてexitすること' do
    ProconBypassMan.config.verbose_bypass_log = false
    procon = StringIO.new(binary)
    gadget = double(:gadget).as_null_object
    allow(ProconBypassMan::Bypass::ProconToSwitch).to receive(:new) { double(:bypass).as_null_object }
    allow(ProconBypassMan::Bypass::SwitchToProcon).to receive(:new) { double(:bypass).as_null_object }
    command_pid = Kernel.fork { described_class.new(procon: procon, gadget: gadget).execute }
    # signal trapが完了するまで適当にsleepする
    sleep 1

    Process.kill('TERM', command_pid)
    result = Process.waitpid2(command_pid)
    expect(result[1].exited?).to eq(true)
  end
end
