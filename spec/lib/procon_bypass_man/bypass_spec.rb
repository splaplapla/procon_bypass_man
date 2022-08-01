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
    let(:bypass) { described_class.new(gadget: dev, procon: dev) }

    subject { described_class.new(gadget: dev, procon: dev).work }

    it do
      double(:processor).tap do |processor|
        expect(processor).to receive(:process)
        expect(ProconBypassMan::Processor).to receive(:new) { processor }
      end

      subject
    end


    # TODO callbackのメソッドを実行したことのテストを書きたい
    xdescribe 'callbacks' do
      it do
        double(:processor).tap do |processor|
          expect(processor).to receive(:process)
          expect(ProconBypassMan::Processor).to receive(:new) { processor }
        end

        # expect(bypass).to receive(:log_after_run)
        # expect(bypass).to receive(:write_procon_display_status)
        subject
      end
    end
  end
end
