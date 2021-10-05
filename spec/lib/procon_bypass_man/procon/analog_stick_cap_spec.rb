require "spec_helper"

describe ProconBypassMan::Procon::AnalogStickCap do
  context '' do
    let(:binary) {
      ["306481008000f2eabe20d7750a88076dfcd90d3c00b0ffc8ff830769fcd40d3600b0ffc8ff7d076afcca0d3300adffcaff000000000000000000000000000000"].pack("H*")
    }
    let(:analog_data) { "f2eabe" }

    describe '#rad' do
      it do
        expect(described_class.new(binary).rad.to_i).to eq(61)
      end
    end

    describe '#hypotenuse' do
      it do
        expect(described_class.new(binary).hypotenuse).to eq(1419.398816)
      end
    end

    describe '#x' do
      it do
        expect(described_class.new(binary).x).to eq(678)
      end
    end

    describe '#y' do
      it do
        expect(described_class.new(binary).y).to eq(1247)
      end
    end

    describe '#position' do
      it do
        position = described_class.new(binary).position
        expect(position.x).to eq(678)
        expect(position.y).to eq(1247)
        # expect(position.to_binary).to eq([analog_data].pack("H*"))
      end
    end

    describe '#capped_position' do
      context 'over' do
        it do
          position = described_class.new(binary).capped_position(cap_hypotenuse: 1100)
          expect(position.x).to eq(525)
          expect(position.y).to eq(966)
          # expect(position.to_binary).not_to eq([analog_data].pack("H*"))
        end
      end
      context 'not over' do
        it do
          position = described_class.new(binary).capped_position(cap_hypotenuse: 4000)
          expect(position.x).to eq(678)
          expect(position.y).to eq(1247)
          # expect(position.to_binary).to eq([analog_data].pack("H*"))
        end
      end
    end
  end

  context 'ニュートラル' do
    let(:binary) {
      ["3036910080004cf87070b7710c28fd1801d10f2500a3ffc2ff25fd1801dd0f2400a4ffc5ff24fd1a01d80f2400a4ffc3ff000000000000000000000000000000"].pack("H*")
    }
    describe '#x' do
      it do
        expect(described_class.new(binary).x).to eq(0)
      end
    end

    describe '#y' do
      it do
        expect(described_class.new(binary).y).to eq(0)
      end
    end

    describe '#hypotenuse' do
      it do
        expect(described_class.new(binary).hypotenuse).to eq(0)
      end
    end
  end
end
