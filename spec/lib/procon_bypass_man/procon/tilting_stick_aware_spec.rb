require "spec_helper"

describe ProconBypassMan::TiltingStickAware do
  describe '.tilting?' do
    subject { described_class.tilting?(power, current_position_x: current_position_x, current_position_y: current_position_y) }

    context 'スティックを傾けるとき' do
      let(:power) { 500 }
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
