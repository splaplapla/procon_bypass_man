require "spec_helper"

describe ProconBypassMan::Procon::AnalogStickCap do
  context '' do
    let(:binary) {
      ["306481008000f2eabe20d7750a88076dfcd90d3c00b0ffc8ff830769fcd40d3600b0ffc8ff7d076afcca0d3300adffcaff000000000000000000000000000000"].pack("H*")
    }
    let(:analog_data) { "f2eabe" }

    describe '#radian' do
      it do
        expect(described_class.new(binary).radian).to eq(3.649624)
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

    describe 'binary_values' do
      it do
        expect(described_class.new(binary).binary_values).to eq("\xF2\xEA\xBE".b)
        expect(described_class.new(binary).binary_values.unpack("H*")).to eq([analog_data])
      end
    end

    describe 'capped_binary_values' do
      context '範囲内' do
        it do
          expect(described_class.new(binary).capped_binary_values(cap_x: [4500, 400], cap_y: [4500, 400]).unpack("H*")).to eq([analog_data])
        end
      end
      it do
        expect(described_class.new(binary).capped_binary_values(cap_x: [2500, 700], cap_y: [2500, 700]).unpack("H*")).to eq(["c4499c"])
      end
      it do
        expect(described_class.new(binary).capped_binary_values(cap_x: [2500, 400], cap_y: [4500, 400]).unpack("H*")).to eq(["c4e9be"])
      end
      it do
        expect(described_class.new(binary).capped_binary_values(cap_x: [4500, 3000], cap_y: [4500, 400]).unpack("H*")).to eq(["b8ebbe"])
      end
    end
  end
end
