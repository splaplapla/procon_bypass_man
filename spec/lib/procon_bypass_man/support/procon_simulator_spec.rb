require "spec_helper"
require "procon_bypass_man/support/procon_simulator"

describe ProconBypassMan::ProconSimulator do
  let(:simulator) { described_class.new }

  describe '#response_counter' do
    it '256の次は0になること' do
      255.times do |index|
        expect(simulator.send(:response_counter)).to eq(index + 1)
      end

      expect(simulator.send(:response_counter)).to eq(256)
      expect(simulator.send(:response_counter)).to eq(0)
    end
  end

  context 'first step' do

    before do
      allow(simulator).to receive(:read).and_return(
        ["0000"].pack("H*"), # none
        ["0000"].pack("H*"), # none
        ["8005"].pack("H*"), # none
        ["0000"].pack("H*"), # none
        ["8001"].pack("H*"), # <<< 810100031f861dd6030400000000000000000000000000000 # procon
        ["8002"].pack("H*"), # <<< 8102...
        ["01000000000000000000033000000000000000000000000000000000000000000000000000000000000000000000000000"].pack("H*"), # <<< 219a810080007bd8789128700a800300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
        ["8004"].pack("H*"), # <<< 309e810080007cc8788f28700a78fd0d00f90ff5ff0100080075fd0900f70ff5ff0200070071fd0900f70ff5ff02000700000000000000000000000000000000
      )
    end

    it do
      expect(simulator.read_once).to eq("0000")
      expect(simulator.read_once).to eq("0000")
      expect(simulator.read_once).to eq("8005")
      expect(simulator.read_once).to eq("0000")
      expect(simulator.read_once).to match("810100032dbd42e9b698000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      expect(simulator.read_once).to match("81020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      expect(simulator.read_once).to match("219a810080007bd8789128700a800300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      expect(simulator.read_once).to match(nil)
    end
  end
end
