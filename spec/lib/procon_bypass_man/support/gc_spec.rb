require "spec_helper"

describe ProconBypassMan::GC  do
  describe '.stop_gc_in' do
    let(:object) do
      object = double(:mock)
      allow(object).to receive(:run) { 1 }
      object
    end

    it do
      expect(described_class.stop_gc_in { object.run }).to eq(1)
      expect(::GC.enable).to eq(false)
    end
  end
end
