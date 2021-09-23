require "spec_helper"

describe ProconBypassMan::Bypass do
  let(:dev) { double(:dev).as_null_object }

  before(:each) do
    $will_interval_1_6 = 0
    $will_interval_0_0_0_5 = 0
  end

  describe '.send_gadget_to_procon!' do
    it do
      monitor = ProconBypassMan::IOMonitor.new(label: "gadget => procon")
      bypass = ProconBypassMan::Bypass.new(gadget: dev, procon: dev, monitor: monitor)
      bypass.send_gadget_to_procon!
    end
  end

  describe '.send_procon_to_gadget!' do
    it do
      monitor = ProconBypassMan::IOMonitor.new(label: "gadget => procon")
      bypass = ProconBypassMan::Bypass.new(gadget: dev, procon: dev, monitor: monitor)
      expect(bypass).to receive(:push_gadget_to_switch_queue)
      bypass.send_procon_to_gadget!
    end
  end
end
