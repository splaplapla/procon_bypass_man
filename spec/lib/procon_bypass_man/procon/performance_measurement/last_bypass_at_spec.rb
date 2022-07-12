require "spec_helper"

describe ProconBypassMan::Procon::PerformanceMeasurement::LastBypassAt do
  it do
    Timecop.freeze(Time.new(2011, 11, 11, 11, 00, 00)) do
      described_class.touch() {}
    end

    Timecop.freeze(Time.new(2011, 11, 11, 11, 00, 01)) do
      described_class.touch do |interval|
        expect(interval).to eq(1.to_i)
      end
    end
  end
end
