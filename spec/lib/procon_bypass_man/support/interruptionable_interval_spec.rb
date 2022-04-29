require "spec_helper"

describe ProconBypassMan::CycleSleep do
  let(:instance) { described_class.new(cycle_interval: cycle_interval, execution_cycle: execution_cycle) }

  describe '#sleep_or_execute' do
    context 'has execution_cycle' do
      let(:cycle_interval) { 0 }
      let(:execution_cycle) { 3 }

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

    context 'has no execution_cycle' do
      let(:cycle_interval) { 0 }
      let(:execution_cycle) { 0 }

      it do
        expect(instance.sleep_or_execute { 1 }).to eq(1)
        expect(instance.sleep_or_execute { 1 }).to eq(1)
        expect(instance.sleep_or_execute { 1 }).to eq(1)
      end
    end
  end
end
