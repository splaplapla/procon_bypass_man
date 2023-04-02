require "spec_helper"

describe ProconBypassMan::ExternalInput::ExternalData do
  describe '.parse!' do
    subject { described_class.parse!(data) }

    context 'not jsonのとき' do
      context '無効な文字を含むカンマ区切り' do
        let(:data) { 'a,b,c' }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: nil, buttons: [:a, :b, :c])
        end
      end

      context 'カンマ区切り' do
        let(:data) { 'a,b' }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: nil, buttons: [:a, :b])
        end
      end

      context '空文字' do
        let(:data) { '' }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: nil, buttons: [])
        end
      end
    end

    context 'jsonのとき' do
      context '空のとき' do
        let(:data) { {}.to_json }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: nil, buttons: [])
        end
      end

      context 'hexがあるとき' do
        let(:data) { { hex: 'a' }.to_json }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: 'a', buttons: [])
        end
      end

      context 'buttonsがあるとき' do
        let(:data) { { hex: 'a', buttons: [:a, :b] }.to_json }

        it 'returns data instance' do
          expect(subject).to have_attributes(hex: 'a', buttons: [:a, :b])
        end
      end
    end
  end
end
