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
end
