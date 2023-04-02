require "spec_helper"
require "serialport"

describe ProconBypassMan::ExternalInput::Channels::SerialPortChannel do
  describe '.read' do
    subject { described_class.new(device_path: '/dev/null').read }

    context 'readできたとき' do
      before do
        serial_port = double(:serial_port)
        expect(serial_port).to receive(:read_nonblock) { 'foo' }
        expect(serial_port).to receive(:read_nonblock) { raise ::IO::EAGAINWaitReadable }
        allow(::SerialPort).to receive(:new) { serial_port }
      end

      it do
        expect(subject).to eq('foo')
      end
    end

    context '改行を含むreadできたとき' do
      before do
        serial_port = double(:serial_port)
        expect(serial_port).to receive(:read_nonblock) { "foo\n" }
        expect(serial_port).to receive(:read_nonblock) { raise ::IO::EAGAINWaitReadable }
        allow(::SerialPort).to receive(:new) { serial_port }
      end

      it do
        expect(subject).to eq('foo')
      end
    end

    context '複数の要素を含むreadできたとき' do
      before do
        serial_port = double(:serial_port)
        expect(serial_port).to receive(:read_nonblock) { "foo\nbar" }
        expect(serial_port).to receive(:read_nonblock) { raise ::IO::EAGAINWaitReadable }
        allow(::SerialPort).to receive(:new) { serial_port }
      end

      it do
        expect(subject).to eq('foo')
      end
    end

    context '複数回readできたとき' do
      before do
        serial_port = double(:serial_port)
        expect(serial_port).to receive(:read_nonblock) { "foo" }
        expect(serial_port).to receive(:read_nonblock) { "bar" }
        expect(serial_port).to receive(:read_nonblock) { raise ::IO::EAGAINWaitReadable }
        allow(::SerialPort).to receive(:new) { serial_port }
      end

      it do
        expect(subject).to eq('foobar')
      end
    end

    context 'readできないのとき' do
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
