require "spec_helper"

describe ProconBypassMan::ExternalInput::ExternalData do
  describe '.parse!' do
    subject { described_class.parse!(data) }

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
        expect(subject).to have_attributes(hex: 'a', buttons: ['a', 'b'])
      end
    end
  end
end
