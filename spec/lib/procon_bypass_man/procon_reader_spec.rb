require "spec_helper"

describe ProconBypassMan::ProconReader do
  let(:binary) { [data].pack("H*") }
  let(:data) { pressed_y_and_b }

  describe '#pressing' do
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    it do
      actual = described_class.new(binary: binary).pressing
      expect(actual).to include(:y, :b)
    end
  end

  describe '#left_analog_stick' do
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    it do
      actual = described_class.new(binary: binary).left_analog_stick
      expect(actual).to eq({:x=>-179, :y=>34})
    end
  end

  describe '#left_analog_stick_by_abs' do
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    it do
      actual = described_class.new(binary: binary).left_analog_stick_by_abs
      expect(actual).to eq({:x=>1945, :y=>1842})
    end
  end

  describe '#gyro' do
    context do
      let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

      it do
        actual = described_class.new(binary: binary).gyro
      end
    end
  end
end
