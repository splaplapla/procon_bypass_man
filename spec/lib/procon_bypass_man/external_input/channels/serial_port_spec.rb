require "spec_helper"

describe ProconBypassMan::ExternalInput::Channels::SerialPortChannel do
  describe '.read' do
    subject { described_class.new(device_path: '/dev/null').read }

    context 'readできないのとき' do
      before do
        serial_port = double(:serial_port)
        expect(serial_port).to receive(:read_nonblock) { 'foo' }
        allow(::SerialPort).to receive(:new) { serial_port }
      end

      it do
        expect(subject).to eq('foo')
      end
    end

    context 'readできたとき' do
      before do
        serial_port = double(:serial_port)
        allow(serial_port).to receive(:read_nonblock) { raise ::IO::EAGAINWaitReadable }
        allow(::SerialPort).to receive(:new) { serial_port }
      end

      it do
        expect(subject).to be_nil
      end
    end
  end
end
