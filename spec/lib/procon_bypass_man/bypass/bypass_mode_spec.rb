require "spec_helper"

describe ProconBypassMan::BypassMode do
  describe '.default_value' do
    it do
      expect(ProconBypassMan::BypassMode.default_value.mode).to eq(:normal)
      expect(ProconBypassMan::BypassMode.default_value.gadget_to_procon_interval).to eq(0.5)
    end
  end

  describe '.to_s' do
    context 'when normal' do
      it do
        bm = ProconBypassMan::BypassMode.new(mode: :normal, gadget_to_procon_interval: 0.9)
        expect(bm.to_s).to eq("normal(0.9)")
      end
    end

    context 'when aggressive' do
      it do
        bm = ProconBypassMan::BypassMode.new(mode: :aggressive, gadget_to_procon_interval: 0.9)
        expect(bm.to_s).to eq("aggressive")
      end
    end
  end
end
