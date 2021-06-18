require "spec_helper"

describe ProconBypassMan::IOMonitor do
  before(:each) do
    ProconBypassMan::IOMonitor.reset!
  end

  describe '.new' do
    it do
      ProconBypassMan::IOMonitor.new(label: "hai")
      ProconBypassMan::IOMonitor.new(label: "hoge")
      expect(ProconBypassMan::IOMonitor.targets.size).to eq(2)
    end
  end

  describe '#record' do
    it do
      time = Time.now
      allow(Time).to receive(:now).and_return(time)
      monitor = ProconBypassMan::IOMonitor.new(label: "hai")
      monitor.record(:before_read)
      monitor.record(:before_read)
      monitor.record(:after_read)
      expect(monitor.table.values).to eq([{:before_read=>2, :after_read=>1}])
    end
  end
end
