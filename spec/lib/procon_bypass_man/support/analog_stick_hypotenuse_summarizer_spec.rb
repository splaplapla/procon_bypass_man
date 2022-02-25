require "spec_helper"

describe ProconBypassMan::AnalogStickHypotenuseSummarizer do
  it do
    map = described_class.new
    Timecop.freeze do
      expect(map.add(5)).to eq(nil)
      expect(map.add(10)).to eq(nil)
    end

    Timecop.freeze(Time.now + 1) do
      actual = map.add(3)
      expect(actual.moving_power).to eq(5)
    end
  end
end
