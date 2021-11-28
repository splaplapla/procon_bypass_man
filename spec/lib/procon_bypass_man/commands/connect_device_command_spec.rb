require "spec_helper"

describe ProconBypassMan::ConnectDeviceCommand do
  describe '.execute!' do
    before do
      allow(ProconBypassMan::DeviceConnector).to receive(:connect)
    end

    it do
      expect { described_class.execute! }.not_to raise_error
    end

    context 'when timeout' do
      before do
        allow(ProconBypassMan::DeviceConnector).to receive(:connect) { raise ProconBypassMan::SafeTimeout::Timeout }
      end

      it do
        expect { described_class.execute! }.to raise_error(::ProconBypassMan::EternalConnectionError)
      end
    end

    context 'when procon not found ' do
      before do
        allow(ProconBypassMan::DeviceConnector).to receive(:connect) { raise ProconBypassMan::DeviceConnector::NotFoundProconError }
      end

      it do
        expect { described_class.execute! }.to raise_error(ProconBypassMan::NotFoundProconError)
      end
    end
  end
end
