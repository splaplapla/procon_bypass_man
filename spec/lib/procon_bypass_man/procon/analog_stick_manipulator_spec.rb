require "spec_helper"

describe ProconBypassMan::Procon::AnalogStickManipulator do
  let(:binary) { [data].pack("H*") }
  let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

  describe 'iv' do
    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new(binary, method: :tilt_left_stick_completely_to_left)
      expect(manipulator.manipulated_abs_x).to eq(400)
    end

    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new(binary, method: :tilt_left_stick_completely_to_right)
      expect(manipulator.manipulated_abs_x).to eq(3400)
    end
  end

  describe '#to_binary' do
    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new(binary, method: :tilt_left_stick_completely_to_right)
      expect(manipulator.to_binary).to be_a(String)
    end
  end

  describe 'method: tilt_left_stick_completely_to_(\d+)deg' do
    before do
      allow(ProconBypassMan.buttons_setting_configuration).to receive(:neutral_position) { OpenStruct.new(x: 2124, y: 1808) }
    end

    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new(binary, method: :tilt_left_stick_completely_to_90deg)
      expect(manipulator.manipulated_abs_x).to eq(-2124)
      expect(manipulator.manipulated_abs_y).to eq(-8)
    end

    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new(binary, method: :tilt_left_stick_completely_to_0deg)
      expect(manipulator.manipulated_abs_x).to eq(-324)
      expect(manipulator.manipulated_abs_y).to eq(-1808)
    end

    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new(binary, method: :tilt_left_stick_completely_to_10deg)
      expect(manipulator.manipulated_abs_x).to eq(-352)
      expect(manipulator.manipulated_abs_y).to eq(-1496)
    end
  end
end
