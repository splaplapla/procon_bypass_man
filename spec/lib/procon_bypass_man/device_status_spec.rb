require "spec_helper"

describe ProconBypassMan::DeviceStatus do
  describe '.change_to_running!' do
    it do
      described_class.change_to_running!
      expect(described_class.current).to eq(ProconBypassMan::DeviceStatus::RUNNING)
    end
  end

  describe '.change_to_connected_but_sleeping!' do
    it do
      described_class.change_to_connected_but_sleeping!
      expect(described_class.current).to eq(ProconBypassMan::DeviceStatus::CONNECTED_BUT_SLEEPING)
    end
  end
end
