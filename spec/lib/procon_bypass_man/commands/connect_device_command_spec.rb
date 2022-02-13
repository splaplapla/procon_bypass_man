require "spec_helper"

describe ProconBypassMan::ConnectDeviceCommand do
  describe '.execute!' do
    subject { described_class.execute! }

    before do
      allow(ProconBypassMan::DeviceConnector).to receive(:connect)
    end

    it do
      expect { subject }.not_to raise_error
    end

    context 'when no has_required_files' do
      before do
        allow(described_class).to receive(:has_required_files?) { false }
      end

      it do
        expect { subject }.to raise_error(ProconBypassMan::NotFoundRequiredFilesError)
      end
    end

    context 'when timeout' do
      before do
        allow(ProconBypassMan::DeviceConnector).to receive(:connect) { raise ProconBypassMan::SafeTimeout::Timeout }
      end

      it do
        expect { subject }.to raise_error(::ProconBypassMan::EternalConnectionError)
      end
    end

    context 'when procon not found ' do
      before do
        allow(ProconBypassMan::DeviceConnector).to receive(:connect) { raise ProconBypassMan::DeviceConnector::NotFoundProconError }
        allow(ProconBypassMan).to receive(:logger) { Logger.new("/dev/null") }
      end

      it do
        expect { subject }.to raise_error(ProconBypassMan::ConnectDeviceCommand::NotFoundProconError)
      end
    end
  end
end
