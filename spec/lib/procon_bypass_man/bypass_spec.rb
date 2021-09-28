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
    let(:output) { ["3075810080009ea7734758750c56fbdc02240f220007001c0055fbdc02250f250009001d005cfbde02240f230007001c00000000000000000000000000000000"].pack("H*") }
    it do
      expect(dev).to receive(:read) { output }
      monitor = ProconBypassMan::IOMonitor.new(label: "gadget => procon")
      bypass = ProconBypassMan::Bypass.new(gadget: dev, procon: dev, monitor: monitor)
      expect(bypass).to receive(:push_gadget_to_switch_queue)
      bypass.send_procon_to_gadget!
    end
  end
end
