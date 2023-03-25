require "spec_helper"

describe ProconBypassMan::ExternalInput do
  describe '.read' do
    subject { described_class.read }

    context 'channelsが空配列' do
      it do
        expect(subject).to be_nil
      end
    end

    context 'channelsに値がある' do
      let(:blank_channel) {
        double(:channel).tap do |channel_stub|
          allow(channel_stub).to receive(:read) { nil }
        end
      }
      let(:channel) {
        double(:channel).tap do |channel_stub|
          allow(channel_stub).to receive(:read) { '1' }
        end
      }

      before do
        ProconBypassMan.config.external_input_channels = [blank_channel, channel]
        ProconBypassMan::ExternalInput.prepare_channels
      end

      after do
        ProconBypassMan.config.external_input_channels = []
        ProconBypassMan::ExternalInput.prepare_channels
      end

      it '値のあるchannelを先に返す' do
        expect(subject).to eq('1')
      end
    end
  end
end
