require "spec_helper"

describe ProconBypassMan::ReadonlyProController do
  let(:binary) { [data].pack("H*") }
  let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
  let(:data) { pressed_y_and_b }

  describe '#pressed' do
    it do
      actual = ProconBypassMan::ReadonlyProController.new(binary: binary).pressed
      expect(actual).to include(:y=>true, :b=>true)
    end
  end

  describe '#left_analog_stick' do
    it do
      actual = ProconBypassMan::ReadonlyProController.new(binary: binary).left_analog_stick
      expect(actual).to eq({:x=>-179, :y=>34})
    end
  end
end
