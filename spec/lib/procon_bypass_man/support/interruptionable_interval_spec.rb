require "spec_helper"

describe ProconBypassMan::InterruptionableSleep do
  let(:instance) { described_class.new(cycle_interval: 0, execution_cycle: 3) }

  describe '#sleep_or_execute' do
    it do
      expect(instance.sleep_or_execute { 1 }).to eq(nil)
      expect(instance.sleep_or_execute { 1 }).to eq(nil)
      expect(instance.sleep_or_execute { 1 }).to eq(nil)
      expect(instance.sleep_or_execute { 1 }).to eq(1)
      expect(instance.sleep_or_execute { 1 }).to eq(nil)
      expect(instance.sleep_or_execute { 1 }).to eq(nil)
      expect(instance.sleep_or_execute { 1 }).to eq(nil)
      expect(instance.sleep_or_execute { 1 }).to eq(1)
    end
  end
end
