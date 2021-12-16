require "spec_helper"

describe ProconBypassMan::Procon::UserOperation do
  describe '#unpress_button' do
    it '特定のbitだけを下げること' do
      binary = ["30f28101800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"].pack("H*")
      o = ProconBypassMan::Procon::UserOperation.new(binary)
      o.unpress_button(:y)
      expect(o.binary.unpack).to eq([
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
      expect(o.binary.unpack).to eq(
        ["30f28101800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"]
      )
    end
  end

  describe '#pressing_all_buttons?' do
    let(:binary) { [pressed_y_and_b].pack("H*") }
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    it do
      uo = ProconBypassMan::Procon::UserOperation.new(binary)
      expect(uo.pressing_all_buttons?([:y, :b])).to eq(true)
    end

    context 'when 集合の一部を与えるとき' do
      it do
        uo = ProconBypassMan::Procon::UserOperation.new(binary)
        expect(uo.pressing_all_buttons?([:y])).to eq(true)
      end
    end

    context 'when provide an empty array' do
      it do
        uo = ProconBypassMan::Procon::UserOperation.new(binary)
        expect(uo.pressing_all_buttons?([])).to eq(true)
      end
    end

    context '押していないボタンを与えるとき' do
      it do
        uo = ProconBypassMan::Procon::UserOperation.new(binary)
        expect(uo.pressing_all_buttons?([:y, :a])).to eq(false)
      end
    end
  end
end
