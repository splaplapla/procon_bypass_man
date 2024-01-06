require "spec_helper"

describe ProconBypassMan::DeviceConnection::ProconColor do
  describe '#to_bytes' do
    subject(:to_bytes) { described_class.new(color_name).to_bytes }

    def decode_bytes(bytes)
      bytes.unpack1('H*').scan(/\w{6}/).map { |x| x.scan(/\w{2}/).join(' ') }
    end

    context 'when color is red' do
      let(:color_name) { :red }

      it { expect(decode_bytes(subject)).to eq ['ff 00 00', 'ff ff ff', 'ff 00 00', 'ff 00 00'] }
    end

    context 'when color is white' do
      let(:color_name) { :white }

      it { expect(decode_bytes(subject)).to eq ['ff ff ff', '00 00 00', 'ff ff ff', 'ff ff ff'] }
    end

    context 'when color is white as String' do
      let(:color_name) { 'white' }

      it { expect(decode_bytes(subject)).to eq ['ff ff ff', '00 00 00', 'ff ff ff', 'ff ff ff'] }
    end
  end

  describe '#valid?' do
    subject(:valid?) { described_class.new(color_name).valid? }

    context 'when color is red' do
      let(:color_name) { :red }

      it { expect(subject).to eq true }
    end

    context 'when color is not_found' do
      let(:color_name) { :not_found }

      it { expect(subject).to eq false }
    end
  end

  describe '#byte_position' do
    context 'when color is red' do
      subject(:byte_position) { described_class.new(:red).byte_position }

      it { expect(subject).to eq(20...(20+(3*4))) }
    end
  end
end
