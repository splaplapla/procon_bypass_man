require "spec_helper"

describe ProconBypassMan::GC  do
  describe '.stop_gc_in' do
    it do
      object = double(:mock)
      def object.run; end
      expect(object).to receive(:run)

      described_class.stop_gc_in { object.run }

      expect(::GC.enable).to eq(false)
    end
  end
end
