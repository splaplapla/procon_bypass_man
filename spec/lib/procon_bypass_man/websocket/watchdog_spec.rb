require "spec_helper"

describe ProconBypassMan::Websocket::Watchdog do
  describe '.active!, .outdated?' do
    it do
      ProconBypassMan::Websocket::Watchdog.active!
      Timecop.freeze(Time.now + 300) do
        expect(ProconBypassMan::Websocket::Watchdog.outdated?).to eq(true)
      end
    end

    it do
      Timecop.freeze do
        ProconBypassMan::Websocket::Watchdog.active!
        expect(ProconBypassMan::Websocket::Watchdog.outdated?).to eq(false)
      end
    end
  end
end
