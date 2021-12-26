require "spec_helper"

describe ProconBypassMan::RunRemotePbmActionDispatchCommand do
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

    context ProconBypassMan::RemotePbmAction::ACTION_CHANGE_PBM_VERSION do
      let(:action) { ProconBypassMan::RemotePbmAction::ACTION_CHANGE_PBM_VERSION }

      it do
        expect(ProconBypassMan::RemotePbmAction::ChangePbmVersionAction).to receive(:new) { double(:o).as_null_object }
        subject
      end
    end

    context ProconBypassMan::RemotePbmAction::ACTION_STOP_PBM do
      let(:action) { ProconBypassMan::RemotePbmAction::ACTION_STOP_PBM }

      it do
        expect(ProconBypassMan::RemotePbmAction::StopPbmAction).to receive(:new) { double(:o).as_null_object }
        subject
      end
    end

    context ProconBypassMan::RemotePbmAction::ACTION_REBOOT_OS do
      let(:action) { ProconBypassMan::RemotePbmAction::ACTION_REBOOT_OS }

      it do
        expect(ProconBypassMan::RemotePbmAction::RebootOsAction).to receive(:new) { double(:o).as_null_object }
        subject
      end
    end

    context 'when to raise ActionUnexpectedError' do
      let(:action) { ProconBypassMan::RemotePbmAction::ACTION_REBOOT_OS }

      it do
        expect(ProconBypassMan::RemotePbmAction::RebootOsAction).to receive(:new) { raise ProconBypassMan::RemotePbmAction::ActionUnexpectedError }
        expect(ProconBypassMan::SendErrorCommand).to receive(:execute)
        subject
      end
    end
  end
end
