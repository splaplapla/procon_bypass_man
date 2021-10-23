require "spec_helper"

describe ProconBypassMan::DeviceConnector do
  subject(:s) { described_class.new(throw_error_if_mismatch: true) }

  around do |example|
    ProconBypassMan.configure do |config|
      config.logger = Logger.new(STDOUT)
    end
    example.run
    ProconBypassMan.configure do |config|
      config.logger = Logger.new(nil)
    end
  end

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
  before do
    allow(s).to receive(:init_devices)
    allow(s).to receive(:switch) { switch }
    allow(s).to receive(:procon) { procon }
  end
  context '間違っている' do
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
  context 'ただしい' do
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

      expect { s.drain_all }.to raise_error(ProconBypassMan::DeviceConnector::BytesMismatchError)
    end
  end
end
