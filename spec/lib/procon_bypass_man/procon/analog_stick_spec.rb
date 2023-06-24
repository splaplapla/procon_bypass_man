require "spec_helper"

describe ProconBypassMan::Procon::AnalogStick do
  let(:binary) { [data].pack("H*") }

  before do
    ProconBypassMan::ButtonsSettingConfiguration.instance.reset!
  end

  describe '#relative_hypotenuse' do
    let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    subject { described_class.new(binary: binary).relative_hypotenuse }

    it do
      expect(subject).to eq(182.200439)
    end
  end
end
