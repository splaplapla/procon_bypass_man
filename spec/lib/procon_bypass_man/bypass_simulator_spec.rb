require "spec_helper"

describe ProconBypassMan::Bypass::Simulator do
  subject(:s) { ProconBypassMan::Bypass::Simulator.new }
  let(:device_mock) do
    double(:device).tap do |d|
      allow(d).to receive(:read_nonblock) { "" }
      allow(d).to receive(:write_nonblock)
    end
  end
  before do
  end
  it do
    s = ProconBypassMan::Bypass::Simulator.new
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
    s.read_procon
  end
end
