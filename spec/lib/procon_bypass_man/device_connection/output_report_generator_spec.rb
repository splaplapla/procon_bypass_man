require "spec_helper"

describe ProconBypassMan::DeviceConnection::OutputReportGenerator do
  let(:instance) { described_class.new }

  describe '#generate_by_step' do
    it do
      expect(instance.generate_by_step(:home_led_on)).to eq([["01", "00", "00" * 8, "38F1F"].join].pack("H*"))
      expect(instance.generate_by_step(:home_led_on)).to eq([["01", "01", "00" * 8, "38F1F"].join].pack("H*"))
    end
  end

  describe '#generate_by_sub_command_with_arg' do
    it do
      expect(instance.generate_by_sub_command_with_arg("3801")).to eq([["01", "00", "00" * 8, "3801"].join].pack("H*"))
      expect(instance.generate_by_sub_command_with_arg("3801")).to eq([["01", "01", "00" * 8, "3801"].join].pack("H*"))
    end
  end
end
