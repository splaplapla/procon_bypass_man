require "spec_helper"

describe ProconBypassMan::Processor do
  describe 'ZR' do
    it do
      not_pushed = "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"
      described_class.new([not_pushed].pack("H*")).process
    end
    it do
      pushed = "3012818a8000b0377246f8750988f5c70bfb011400e9ff180083f5d00bf9011100ecff190088f5d10bf9011000f1ff1c00000000000000000000000000000000"
      described_class.new([pushed].pack("H*")).process
    end
  end
end
