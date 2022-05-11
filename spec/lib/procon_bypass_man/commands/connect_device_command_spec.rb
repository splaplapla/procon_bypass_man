require "spec_helper"

describe ProconBypassMan::DeviceConnection::Command do
  describe '.execute!' do
    subject { described_class.execute! }

    before do
      allow(ProconBypassMan::DeviceConnection::Executer).to receive(:connect)
    end

    it do
      expect { subject }.not_to raise_error
    end

    context 'when timeout' do
      before do
        allow(ProconBypassMan::DeviceConnection::Executer).to receive(:connect) { raise ProconBypassMan::SafeTimeout::Timeout }
      end

      it do
        expect { subject }.to raise_error(::ProconBypassMan::EternalConnectionError)
      end
    end

    context 'when procon not found ' do
      before do
        allow(ProconBypassMan::DeviceConnection::Executer).to receive(:connect) { raise ProconBypassMan::DeviceConnection::NotFoundProconError }
        allow(ProconBypassMan).to receive(:logger) { Logger.new("/dev/null") }
      end

      it do
        expect { subject }.to raise_error(ProconBypassMan::DeviceConnection::NotFoundProconError)
      end
    end
  end
end
