require "spec_helper"

describe ProconBypassMan::ExternalInput::ExternalData do
  describe '.parse!' do
    subject { described_class.parse!(data) }

    context '空のとき' do
      let(:data) { {}.to_json }

      it 'returns data instance' do
        expect(subject).to have_attributes(raw_binary: nil, buttons: [])
      end
    end

    context 'raw_binaryがあるとき' do
      let(:data) { { raw_binary: 'a' }.to_json }

      it 'returns data instance' do
        expect(subject).to have_attributes(raw_binary: 'a', buttons: [])
      end
    end

    context 'buttonsがあるとき' do
      let(:data) { { raw_binary: 'a', buttons: [:a, :b] }.to_json }

      it 'returns data instance' do
        expect(subject).to have_attributes(raw_binary: 'a', buttons: ['a', 'b'])
      end
    end
  end
end
