require "spec_helper"

describe ProconBypassMan::ExternalInput::BootMessage do
  describe '#to_s' do
    subject { described_class.new(channels: channels).to_s }

    context 'when provides []' do
      let(:channels) { [] }

      it do
        expect(subject).to eq('DISABLE')
      end
    end

    context 'when provides any' do
      let(:channels) { [MockSerialPortChannel.new, MockTCPIPChannel.new] }

      before do
        stub_const('MockSerialPortChannel', Class.new(ProconBypassMan::ExternalInput::Channels::SerialPortChannel) do
          def initialize(*args); end
        end)
        stub_const('MockTCPIPChannel', Class.new(ProconBypassMan::ExternalInput::Channels::TCPIPChannel) do
          def initialize(*_args)
            @port = 1234
          end
        end)
      end

      it do
        expect(subject).to eq("SerialPort, TCPIP(port: 1234)")
      end
    end
  end
end
