require "spec_helper"

describe ProconBypassMan::Procon::AnalogStickManipulator do
  describe 'iv' do
    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new("", method: :tilt_left_stick_completely_to_left)
      expect(manipulator.power_level).to eq("completely")
      expect(manipulator.direction).to eq("left")
    end

    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new("", method: :tilt_left_stick_completely_to_right)
      expect(manipulator.power_level).to eq("completely")
      expect(manipulator.direction).to eq("right")
    end
  end

  describe '#to_binary' do
    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new("", method: :tilt_left_stick_completely_to_right)
      expect(manipulator.to_binary).to be_a(String)
    end
  end
end
