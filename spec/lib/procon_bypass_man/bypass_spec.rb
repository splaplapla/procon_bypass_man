require "spec_helper"

describe ProconBypassMan::Bypass do
  describe ProconBypassMan::Bypass::SwitchToProcon do
    let(:output) { ["30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"].pack("H*") }
    let(:dev) { StringIO.new(output) }

    subject { described_class.new(gadget: dev, procon: dev).run }

    it do
      subject
    end
  end

  describe ProconBypassMan::Bypass::ProconToSwitch do
    let(:output) { ["30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"].pack("H*") }
    let(:dev) { StringIO.new(output) }

    subject { described_class.new(gadget: dev, procon: dev).run }

    it do
      double(:processor).tap do |processor|
        expect(processor).to receive(:process)
        expect(ProconBypassMan::Processor).to receive(:new) { processor }
      end

      subject
    end
  end
end
