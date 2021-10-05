require "spec_helper"

describe ProconBypassMan::Procon::AnalogStickCap do
  context '' do
    let(:binary) {
      ["306481008000f2eabe20d7750a88076dfcd90d3c00b0ffc8ff830769fcd40d3600b0ffc8ff7d076afcca0d3300adffcaff000000000000000000000000000000"].pack("H*")
    }
    let(:analog_data) { "f2eabe" }

    describe '#rad' do
      it do
        expect(described_class.new(binary).rad).to eq(47.464076)
      end
    end

    describe '#hypotenuse' do
      it do
        expect(described_class.new(binary).hypotenuse).to eq(4144.649562)
      end
    end

    describe '#x' do
      it do
        expect(described_class.new(binary).x).to eq(2802)
      end
    end

    describe '#y' do
      it do
        expect(described_class.new(binary).y).to eq(3054)
      end
    end

    describe '#position' do
      it do
        position = described_class.new(binary).position
        expect(position.x).to eq(2802)
        expect(position.y).to eq(3054)
        expect(position.to_binary).to eq([analog_data].pack("H*"))
      end
    end

    describe '#capped_position' do
      context 'over' do
        it do
          position = described_class.new(binary).capped_position(cap_hypotenuse: 1100)
          expect(position.x).to eq(2560)
          expect(position.y).to eq(2790)
          expect(position.to_binary).not_to eq([analog_data].pack("H*"))
        end
      end
      context 'not over' do
        it do
          position = described_class.new(binary).capped_position(cap_hypotenuse: 2100)
          expect(position.x).to eq(2802)
          expect(position.y).to eq(3054)
          expect(position.to_binary).to eq([analog_data].pack("H*"))
        end
      end
    end
  end
end
