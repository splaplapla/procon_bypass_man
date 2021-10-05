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
    it { expect(described_class.new(binary).x).to eq(678) }
    it { expect(described_class.new(binary).y).to eq(1247) }
    it { expect(described_class.new(binary).hypotenuse.to_i).to eq(1419) }
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
      it { expect(described_class.new(binary).x).to eq(0) }
      it { expect(described_class.new(binary).y).to eq(0) }
      it { expect(described_class.new(binary).hypotenuse).to eq(0) }
    end
  end

  context '左' do
    let(:binary) {
      ["3028810080005252717977730b82fe4e010c102600a6ffc8ff84fe4e0109102600a6ffc8ff85fe4e0108102600a7ffc8ff000000000000000000000000000000"].pack("H*")
    }
    describe '#x' do
      it { expect(described_class.new(binary).x).to eq(-1530) }
      it { expect(described_class.new(binary).y).to eq(6) }
      it { expect(described_class.new(binary).hypotenuse.to_i).to eq(1530) }
    end
  end

  context '左うえ' do
    let(:binary) {
      ["30b6810080006773b55ab76f0b5bfe1d010a101e00aeffc6ff5cfe1d0109101d00aeffc6ff5cfe1d0108101b00afffc5ff000000000000000000000000000000"].pack("H*")
    }
    describe '#x' do
      it { expect(described_class.new(binary).x).to eq(-1253) }
      it { expect(described_class.new(binary).y).to eq(1096) }
      it { expect(described_class.new(binary).hypotenuse.to_i).to eq(1664) }
    end
  end

end
