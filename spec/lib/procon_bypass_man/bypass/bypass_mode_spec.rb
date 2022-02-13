require "spec_helper"

describe ProconBypassMan::BypassMode do
  describe '.default' do
    it do
      expect(ProconBypassMan::BypassMode.default.mode).to eq(:normal)
      expect(ProconBypassMan::BypassMode.default.gadget_to_procon_interval).to eq(0.5)
    end
  end
end