require "spec_helper"

describe ProconBypassMan::DeviceConnection::Executer do
  subject(:s) { described_class.new(throw_error_if_mismatch: true) }

  describe '#drain_all' do
    let(:switch) { NotImplementedError }
    let(:procon) { NotImplementedError }

    before do
      allow(s).to receive(:init_devices)
      allow(s).to receive(:switch) { switch }
      allow(s).to receive(:procon) { procon }
    end

    context '当初想定していたIOのとき' do
      let(:switch) do
        double(:switch).tap do |d|
          allow(d).to receive(:read_nonblock).and_return(
            ["0000"].pack("H*"),
            ["0000"].pack("H*"),
            ["8005"].pack("H*"),
            ["0000"].pack("H*"),
            ["8001"].pack("H*"),
            ["8002"].pack("H*"),
            ["0100"].pack("H*"),
            ["8004"].pack("H*"),
          )
          allow(d).to receive(:write_nonblock)
        end
      end
      let(:procon) do
        double(:procon).tap do |d|
          allow(d).to receive(:read_nonblock).and_return(
            ["8101"].pack("H*"),
            ["8102"].pack("H*"),
            ["21"].pack("H*"),
          )
          allow(d).to receive(:write_nonblock)
        end
      end

      context 'ただしい' do
        it do
          s.add([
            ["0000"],
            ["0000"],
            ["8005"],
            ["0000"],
          ], read_from: :switch)
          # 1
          s.add([["8001"]], read_from: :switch)
          s.add([/^8101/], read_from: :procon)
          # 2
          s.add([["8002"]], read_from: :switch)
          s.add([/^8102/], read_from: :procon)
          # 3
          s.add([/^0100/], read_from: :switch)
          s.add([/^21/], read_from: :procon)
          # 4
          s.add([["8004"]], read_from: :switch)

          expect { s.drain_all }.not_to raise_error
        end
      end

      context '間違っている' do
        it do
          s.add([
            ["0000"],
            ["0000"],
            ["8005"],
            ["0010"],
          ], read_from: :switch)
          # 1
          s.add([["8001"]], read_from: :switch)
          s.add([/^8101/], read_from: :procon)
          # 2
          s.add([["8002"]], read_from: :switch)
          s.add([/^8102/], read_from: :procon)
          # 3
          s.add([/^0100/], read_from: :switch)
          s.add([/^21/], read_from: :procon)
          # 4
          s.add([["8004"]], read_from: :switch)

          expect { s.drain_all }.to raise_error(ProconBypassMan::DeviceConnection::BytesMismatchError)
        end
      end
    end
  end

  describe '#connect' do
    let(:switch) do
      double(:switch).tap do |d|
        allow(d).to receive(:read_nonblock).and_return(
          ["0000"].pack("H*"),
          ["0000"].pack("H*"),
          ["8005"].pack("H*"),
          ["0000"].pack("H*"),
          ["8001"].pack("H*"),
          ["8002"].pack("H*"),
          ["0100"].pack("H*"),
          ["8004"].pack("H*"),
        )
        allow(d).to receive(:write_nonblock)
      end
    end
    let(:procon) do
      double(:procon).tap do |d|
        allow(d).to receive(:read_nonblock).and_return(
          ["8101"].pack("H*"),
          ["8102"].pack("H*"),
          ["21"].pack("H*"),
        )
        allow(d).to receive(:read).and_return(
          ["8101030000000000000000"].pack("H*"),
          ["810100032DBD42E9B698000"].pack("H*"),
          # 8001をwriteする
          ["8102"].pack("H*"),
          # 10をwriteする
        )
        allow(d).to receive(:write_nonblock)
      end
    end

    before do
      allow(s).to receive(:init_devices)
      allow(s).to receive(:switch) { switch }
      allow(s).to receive(:procon) { procon }
    end

    it do
      allow(described_class).to receive(:new_with_default_args) { s }
      expect(described_class.execute!).to eq([switch, procon])
    end
  end

  describe '#init_devices' do
    context 'ProconBypassMan::DeviceProconFinder.findがnilを返すとき' do
      before do
        allow(ProconBypassMan::DeviceProconFinder).to receive(:find)
      end
      it do
        expect { s.init_devices }.to raise_error(ProconBypassMan::DeviceConnection::NotFoundProconError)
      end
    end
  end
end
