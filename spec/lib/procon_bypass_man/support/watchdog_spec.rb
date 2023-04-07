require "spec_helper"

RSpec.describe ProconBypassMan::Watchdog do
  describe '.active!, .outdated?' do
    let(:watchdog) { described_class.new }

    it do
      watchdog.active!
      Timecop.freeze(Time.now + 300) do
        expect(watchdog.outdated?).to eq(true)
      end
    end

    it do
      Timecop.freeze do
        watchdog.active!
        expect(watchdog.outdated?).to eq(false)
      end
    end
  end
end
