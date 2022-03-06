require "spec_helper"

describe ProconBypassMan::Procon::AnalogStickManipulator do
  describe 'iv' do
    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new("", method: :tilt_full_left_stick)
      expect(manipulator.power_level).to eq("full")
      expect(manipulator.direction).to eq("left")
    end

    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new("", method: :tilt_full_right_stick)
      expect(manipulator.power_level).to eq("full")
      expect(manipulator.direction).to eq("right")
    end
  end

  describe '#to_binary' do
    it do
      manipulator = ProconBypassMan::Procon::AnalogStickManipulator.new("", method: :tilt_full_left_stick)
      expect(manipulator.to_binary).to be_a(String)
    end
  end
end
