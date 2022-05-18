require "spec_helper"

describe ProconBypassMan::DeviceConnection::Command do
  describe '.execute!' do
    subject { described_class.execute! }

    before do
      allow(ProconBypassMan::DeviceConnection::Executer).to receive(:execute!)
      allow(ProconBypassMan::DeviceConnection::PreBypass).to receive(:new) { double(:x).as_null_object }
      allow(ProconBypassMan::DeviceConnection::ProconSettingOverrider).to receive(:new) { double(:x).as_null_object }
    end

    it do
      expect { subject }.not_to raise_error
    end

    context 'when timeout in conditional route' do
      before do
        allow(ProconBypassMan::DeviceConnection::Executer).to receive(:execute!) { raise ProconBypassMan::DeviceConnection::TimeoutErrorInConditionalRoute }
      end

      it do
        expect { subject }.to raise_error(ProconBypassMan::DeviceConnection::TimeoutError)
      end

      it do
        expect(ProconBypassMan::SendErrorCommand).to receive(:execute).exactly(4).times
        begin
          subject
        rescue ProconBypassMan::DeviceConnection::TimeoutError
          # no-op
        end
      end
    end

    context 'when timeout' do
      before do
        allow(ProconBypassMan::DeviceConnection::Executer).to receive(:execute!) { raise ProconBypassMan::SafeTimeout::Timeout }
      end

      it do
        expect { subject }.to raise_error(ProconBypassMan::DeviceConnection::TimeoutError)
      end
    end

    context 'when procon not found ' do
      before do
        allow(ProconBypassMan::DeviceConnection::Executer).to receive(:execute!) { raise ProconBypassMan::DeviceConnection::NotFoundProconError }
        allow(ProconBypassMan).to receive(:logger) { Logger.new("/dev/null") }
      end

      it do
        expect { subject }.to raise_error(ProconBypassMan::DeviceConnection::NotFoundProconError)
      end
    end
  end
end
