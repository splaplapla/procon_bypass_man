require "spec_helper"

describe ProconBypassMan::RumbleBinary do
  let(:binary) { [data].pack("H*") }
  let(:data) { "100d0001404000014040" }
  let(:instance) { ProconBypassMan::RumbleBinary.new(binary: binary) }

  describe '#unpack' do
    it do
      expect(instance.unpack).to eq([data])
    end
  end

  describe '#raw' do
    it do
      expect(instance.raw).to eq(binary)
    end
  end
end
