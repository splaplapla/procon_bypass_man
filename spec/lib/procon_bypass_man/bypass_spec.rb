require "spec_helper"

describe ProconBypassMan::Bypass do
  before(:each) do
    $will_interval_1_6 = 0
    $will_interval_1_6 = 0
  end

  describe '.send_gadget_to_procon!' do
    it do
      monitor = ProconBypassMan::IOMonitor.new(label: "gadget => procon")
      dev = File.open(File::NULL, "w")
      ProconBypassMan::Bypass.new(gadget: dev, procon: dev, monitor: monitor)
    end
  end
end
