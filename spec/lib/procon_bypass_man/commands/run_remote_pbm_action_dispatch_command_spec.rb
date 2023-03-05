require "spec_helper"

describe ProconBypassMan::RemoteAction::RemotePbmJob::RunRemotePbmJobDispatchCommand do
  describe '.execute' do
    subject { described_class.execute(action: action, uuid: "a", job_args: {}) }

    describe 'error handler' do
      context 'when unknown action' do
        let(:action) { :unkown }

        it 'thorw error' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_CHANGE_PBM_VERSION do
      let(:action) { ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_CHANGE_PBM_VERSION }

      it do
        expect(ProconBypassMan::RemoteAction::RemotePbmJob::ChangePbmVersionAction).to receive(:new) { double(:o).as_null_object }
        subject
      end
    end

    context ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_STOP_PBM do
      let(:action) { ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_STOP_PBM }

      it do
        expect(ProconBypassMan::RemoteAction::RemotePbmJob::StopPbmJob).to receive(:new) { double(:o).as_null_object }
        subject
      end
    end

    context ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_REBOOT_OS do
      let(:action) { ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_REBOOT_OS }

      it do
        expect(ProconBypassMan::RemoteAction::RemotePbmJob::RebootOsAction).to receive(:new) { double(:o).as_null_object }
        subject
      end
    end

    context 'when to raise ActionUnexpectedError' do
      let(:action) { ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_REBOOT_OS }

      it do
        expect(ProconBypassMan::RemoteAction::RemotePbmJob::RebootOsAction).to receive(:new) { raise ProconBypassMan::RemoteAction::RemotePbmJob::ActionUnexpectedError }
        expect(ProconBypassMan::SendErrorCommand).to receive(:execute)
        subject
      end
    end
  end
end
