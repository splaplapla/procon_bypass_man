require "spec_helper"

describe ProconBypassMan::Procon::UserOperation do
  describe '#unpress_button' do
    it '特定のbitだけを下げること' do
      binary = ["30f28101800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"].pack("H*")
      o = ProconBypassMan::Procon::UserOperation.new(binary)
      o.unpress_button(:y)
      expect(o.binary.unpack("H*")).to eq([
        "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"
      ])
    end
  end

  describe '#press_button' do
    let(:no_action_binary) do
      ["30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"].pack("H*")
    end
    it '特定のbitだけを立てること' do
      o = ProconBypassMan::Procon::UserOperation.new(no_action_binary)
      o.press_button(:y)
      expect(o.binary.unpack("H*")).to eq(
        ["30f28101800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"]
      )
    end
  end
end
