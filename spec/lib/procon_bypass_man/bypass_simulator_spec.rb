require "spec_helper"

describe ProconBypassMan::BypassSupporter do
  subject(:s) { described_class.new }
  let(:device_mock) do
    double(:device).tap do |d|
      allow(d).to receive(:read_nonblock) { "" }
      allow(d).to receive(:write_nonblock)
    end
  end
  before do
  end
  it do
    s = described_class.new
    allow(s).to receive(:init_devices)
    allow(s).to receive(:switch) { device_mock }
    allow(s).to receive(:procon) { device_mock }

    s.add([
      ["0000"],
      ["0000"],
      ["8005"],
      ["0000"],
      ["8001"],
    ], read_from: :switch)
    s.drain_all
    s.write_switch("213c910080005db7723d48720a800300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
  end
end
