require "spec_helper"

describe ProconBypassMan::BypassMode do
  describe '.default_value' do
    it do
      expect(ProconBypassMan::BypassMode.default_value.mode).to eq(:normal)
      expect(ProconBypassMan::BypassMode.default_value.gadget_to_procon_interval).to eq(0.5)
    end
  end
end
