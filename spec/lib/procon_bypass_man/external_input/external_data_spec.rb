require "spec_helper"

describe ProconBypassMan::ExternalInput::ExternalData do
  describe '.parse!' do
    subject { described_class.parse!(data) }

    context 'not jsonのとき' do
      context 'unpressな文字を含むカンマ区切り' do
        let(:data) { 'a,una,unb,c,' }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: nil, press_buttons: [:a], unpress_buttons: [:a, :b])
        end
      end

      context '無効な文字を含むカンマ区切り' do
        let(:data) { 'a,b,c,' }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: nil, press_buttons: [:a, :b], unpress_buttons: [])
        end
      end

      context '複数のカンマ区切り' do
        let(:data) { 'a,b,' }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: nil, press_buttons: [:a, :b], unpress_buttons: [])
        end
      end

      context 'カンマ区切り' do
        let(:data) { 'a,b' }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: nil, press_buttons: [:a], unpress_buttons: [])
        end
      end

      context '空文字' do
        let(:data) { '' }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: nil, press_buttons: [], unpress_buttons: [])
        end
      end
    end

    context 'jsonのとき' do
      context '空のとき' do
        let(:data) { {}.to_json }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: nil, press_buttons: [], unpress_buttons: [])
        end
      end

      context 'hexがあるとき' do
        let(:data) { { hex: 'a' }.to_json }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: 'a', press_buttons: [], unpress_buttons: [])
        end
      end

      context 'buttonsがあるとき' do
        let(:data) { { hex: 'a', buttons: [:a, :b] }.to_json }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: 'a', press_buttons: [:a, :b], unpress_buttons: [])
        end
      end
    end
  end
end
