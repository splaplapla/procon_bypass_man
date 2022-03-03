require "spec_helper"

describe ProconBypassMan::AnalogStickTiltingPowerScaler do
  describe ProconBypassMan::AnalogStickTiltingPowerScaler::PowerChunk do
    describe '.tilting?' do
      let(:instance) { described_class.new(nil) }

      subject { instance.tilting?(current_position_x: current_position_x, current_position_y: current_position_y) }

      before do
        allow(instance).to receive(:moving_power) { power }
      end

      context 'スティックを傾けるとき' do
        let(:power) { 600 }
        let(:current_position_x) { 1000 }
        let(:current_position_y) { 1000 }

        it do
          expect(subject).to eq(true)
        end
      end

      context 'スティックを戻すとき' do
        let(:power) { 1000 }
        let(:current_position_x) { 10 }
        let(:current_position_y) { 10 }

        it do
          expect(subject).to eq(false)
        end
      end

      context '止まっている' do
        let(:power) { 100 }
        let(:current_position_x) { 10 }
        let(:current_position_y) { 10 }

        it do
          expect(subject).to eq(false)
        end
      end
    end
  end

  it do
    map = described_class.new
    Timecop.freeze do
      expect(map.add_sample(5)).to eq(nil)
      expect(map.add_sample(10)).to eq(nil)
    end

    Timecop.freeze(Time.now + 1) do
      actual = map.add_sample(3)
      expect(actual.moving_power).to eq(5)
    end
  end
end
