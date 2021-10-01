require "spec_helper"

describe ProconBypassMan::Bypass do
  let(:dev) { double(:dev).as_null_object }

  describe '.send_gadget_to_procon!' do
    it do
      monitor = ProconBypassMan::IOMonitor.new(label: "gadget => procon")
      bypass = ProconBypassMan::Bypass.new(gadget: dev, procon: dev, monitor: monitor)
      bypass.send_gadget_to_procon!
    end
  end

  describe '.send_procon_to_gadget!' do
    let(:output) { ["30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"].pack("H*") }
    it do
      expect(dev).to receive(:read) { output }
      double(:processor).tap do |processor|
        expect(processor).to receive(:process)
        expect(ProconBypassMan::Processor).to receive(:new) { processor }
      end
      monitor = ProconBypassMan::IOMonitor.new(label: "gadget => procon")
      bypass = ProconBypassMan::Bypass.new(gadget: dev, procon: dev, monitor: monitor)
      bypass.send_procon_to_gadget!
    end
  end
end
