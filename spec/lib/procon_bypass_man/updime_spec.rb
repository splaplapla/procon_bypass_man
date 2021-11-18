require "spec_helper"

describe ProconBypassMan::Uptime do
  describe '.from_boot' do
    it do
      uptime = ProconBypassMan::Uptime.new(uptime_cmd_result: '2021-11-11 19:40:43')
      Timecop.freeze '2021-11-11 19:40:49' do
        expect(uptime.from_boot).to eq(6)
      end
    end
  end
end
