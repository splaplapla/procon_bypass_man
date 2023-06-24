require "spec_helper"

describe ProconBypassMan::RumbleBinary do
  let(:binary) { [data].pack("H*") }
  let(:instance) { ProconBypassMan::RumbleBinary.new(binary: binary) }

  describe '#unpack' do
    let(:data) { "100d0001404000014040" }
    it do
      expect(instance.unpack).to eq([data])
    end
  end

  describe '#raw' do
  let(:data) { "100d0001404000014040" }
  it do
    expect(instance.raw).to eq(binary)
  end
  end

  describe 'noop!' do
    context 'ニュートラル' do
      let(:data) { "100d0001404000014040" }
      it do
        expect(instance.noop!).to eq(binary)
      end
    end

    context 'not ニュートラル' do
      let(:data) { "1008be176347be176347" }
      it do
        instance.noop!
        expect(instance.unpack).to eq(["10080001404000014040"])
      end
    end
  end
end
