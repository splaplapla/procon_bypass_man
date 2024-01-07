require "spec_helper"

describe ProconBypassMan::Procon::AnalogStickCap do
  let(:default_x) { 2124 }
  let(:default_y) { 1807 }
  def with_default_x(n)
    return default_x + n
  end
  def with_default_y(n)
    return default_y + n
  end

  before do
    ProconBypassMan.buttons_setting_configuration.set_neutral_position(2124, 1807)
  end

  context 'detail' do
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
        expect(position.x).to eq(with_default_x 678)
        expect(position.y).to eq(with_default_y 1247)
        # expect(position.to_binary).to eq([analog_data].pack("H*"))
      end
    end

    describe '#capped_position' do
      context 'over' do
        it do
          position = described_class.new(binary).capped_position(cap_hypotenuse: 1100)
          expect(position.x).to eq(with_default_x 525)
          expect(position.y).to eq(with_default_y 966)
          # expect(position.to_binary).not_to eq([analog_data].pack("H*"))
        end
      end
      context 'not over' do
        it do
          position = described_class.new(binary).capped_position(cap_hypotenuse: 4000)
          expect(position.x).to eq(with_default_x 678)
          expect(position.y).to eq(with_default_y 1247)
          # expect(position.to_binary).to eq([analog_data].pack("H*"))
        end
      end
    end
  end

  context 'ニュートラル' do
    let(:binary) {
      ["3036910080004cf87070b7710c28fd1801d10f2500a3ffc2ff25fd1801dd0f2400a4ffc5ff24fd1a01d80f2400a4ffc3ff000000000000000000000000000000"].pack("H*")
    }
    it { expect(described_class.new(binary).x).to eq(0) }
    it { expect(described_class.new(binary).y).to eq(0) }
    it { expect(described_class.new(binary).hypotenuse).to eq(0) }
    it { expect(described_class.new(binary).rad).not_to be_a(Integer) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 2000).x).to eq(with_default_x 0) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 2000).y).to eq(with_default_y 0) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1500).x).to eq(with_default_x 0) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1500).y).to eq(with_default_y 0) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1000).x).to eq(with_default_x 0) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1000).y).to eq(with_default_y 0) }
    # it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1000).to_binary).to eq("\x00\x00\x00") }
  end

  context '左' do
    let(:binary) {
      ["3028810080005252717977730b82fe4e010c102600a6ffc8ff84fe4e0109102600a6ffc8ff85fe4e0108102600a7ffc8ff000000000000000000000000000000"].pack("H*")
    }
    it { expect(described_class.new(binary).x).to eq(-1530) }
    it { expect(described_class.new(binary).y).to eq(6) }
    it { expect(described_class.new(binary).hypotenuse.to_i).to eq(1530) }
    it { expect(described_class.new(binary).rad).to eq(-0.224689) }
  end

  context '左うえ' do
    let(:binary) {
      ["30b6810080006773b55ab76f0b5bfe1d010a101e00aeffc6ff5cfe1d0109101d00aeffc6ff5cfe1d0108101b00afffc5ff000000000000000000000000000000"].pack("H*")
    }
    it { expect(described_class.new(binary).x).to eq(-1253) }
    it { expect(described_class.new(binary).y).to eq(1096) }
    it { expect(described_class.new(binary).position.x).to eq(with_default_x(-1253)) }
    it { expect(described_class.new(binary).position.y).to eq(with_default_y 1096) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 2000).x).to eq(with_default_x(-1253)) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 2000).y).to eq(with_default_y 1096) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1500).x).to eq(994) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1500).y).to eq(2794) }
    it { expect(described_class.new(binary).hypotenuse.to_i).to eq(1664) }
    it { expect(described_class.new(binary).rad).to eq(-41.176212) }
  end

  context '上' do
    let(:binary) {
      ["3059810080006f28de88a7720b38fdf0ffe40f2400a5ffc5ff38fdeeffe20f2300a7ffc3ff3dfdf1ffe50f2400a8ffc5ff000000000000000000000000000000"].pack("H*")
    }
    it { expect(described_class.new(binary).x).to eq(35) }
    it { expect(described_class.new(binary).y).to eq(1747) }
    it { expect(described_class.new(binary).hypotenuse.to_i).to eq(1747) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 2000).x).to eq(with_default_x 35) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 2000).y).to eq(with_default_y 1747) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1500).x).to eq(with_default_x 30) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1500).y).to eq(with_default_y 1499) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1000).x).to eq(with_default_x 20) }
    it { expect(described_class.new(binary).capped_position(cap_hypotenuse: 1000).y).to eq(with_default_y 999) }
    it { expect(described_class.new(binary).rad).to eq(88.85227) }
  end

  context 'バグが起きた特定の並び' do
    let(:binary) {
      ["305b8108800045087254c7730975fd0900f00f2400a5ffc5ff6ffd0600f40f2200a3ffc5ff73fd0800f60f2100a4ffc5ff000000000000000000000000000000"].pack("H*")
    }
    it { expect(described_class.new(binary).position.to_binary).to eq("E\br") }
  end
end
