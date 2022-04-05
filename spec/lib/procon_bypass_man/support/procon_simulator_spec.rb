require "spec_helper"
require "procon_bypass_man/support/procon_simulator"

describe ProconBypassMan::ProconSimulator do
  let(:initial_input) { ProconBypassMan::ProconSimulator::UART_INITIAL_INPUT }
  let(:device_info) { ProconBypassMan::ProconSimulator::UART_DEVICE_INFO }
  let(:simulator) { described_class.new }

  describe '#response_counter' do
    it '256の次は0になること' do
      255.times do |index|
        simulator.send(:response_counter)
      end

      expect(simulator.send(:response_counter)).to eq("256")
      expect(simulator.send(:response_counter)).to eq("00")
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
        ["01000000000000000000033000000000000000000000000000000000000000000000000000000000000000000000000000"].pack("H*"), # 01-03
        ["8004"].pack("H*"), # <<< 309e810080007cc8788f28700a78fd0d00f90ff5ff0100080075fd0900f70ff5ff0200070071fd0900f70ff5ff02000700000000000000000000000000000000
        ["01000000000000000000480000000000000000000000000000000000000000000000000000000000000000000000000000"].pack("H*"), # 01-48
        ["01010000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000"].pack("H*"), # 01-02
        ["01020000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000"].pack("H*"), # 01-08
        ["01030000000000000000100060000010000000000000000000000000000000000000000000000000000000000000000000"].pack("H*"), # 01-10-0060, Serial number
        ["0104000000000000000010506000000d000000000000000000000000000000000000000000000000000000000000000000"].pack("H*"), # Controller Color
      )
    end

    it do
      expect(simulator.read_once).to eq("0000")
      expect(simulator.read_once).to eq("0000")
      expect(simulator.read_once).to eq("8005")
      expect(simulator.read_once).to eq("0000")
      expect(simulator.read_once).to match("810100032dbd42e9b698000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      expect(simulator.read_once).to match("81020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      expect(simulator.read_once).to match(/21..#{initial_input}800300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/) # 01-03
      expect(simulator.read_once).to match(nil)
      expect(simulator.instance_eval { @procon_simulator_thread }).not_to be_nil
      expect(simulator.read_once).to match(/21..#{initial_input}804800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/) # 01-48
      expect(simulator.read_once).to match(/21..#{initial_input}8202#{device_info          }00000000000000000000000000000000000000000000000000000000000000000000000000/) # 01-02
      expect(simulator.read_once).to match(/21..#{initial_input}800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/) # 01-08
      expect(simulator.read_once).to match(/21..#{initial_input}90100060000010ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000/) # 01-10-0060, Serial number
      expect(simulator.read_once).to match(/21..#{initial_input}90105060000010bc114275a928ffffffffffffff00000000000000000000000000000000000000000000000000000000000000/) # Controller Color
    end
  end
end
