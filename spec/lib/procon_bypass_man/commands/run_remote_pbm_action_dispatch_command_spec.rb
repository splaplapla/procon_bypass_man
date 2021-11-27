require "spec_helper"

describe ProconBypassMan::RunRemotePbmActionDispatchCommand do
  describe '.execute' do
    subject { described_class.execute(action: action, uuid: "a") }

    context ProconBypassMan::RemotePbmAction::CHANGE_PBM_VERSION do
      let(:action) { ProconBypassMan::RemotePbmAction::CHANGE_PBM_VERSION }

      it do
        expect(ProconBypassMan::RemotePbmAction::ChangePbmVersionAction).to receive(:new) { double(:o).as_null_object }
        subject
      end
    end

    context ProconBypassMan::RemotePbmAction::REBOOT_PBM do
      let(:action) { ProconBypassMan::RemotePbmAction::REBOOT_PBM }

      it do
        expect(ProconBypassMan::RemotePbmAction::RebootPbmAction).to receive(:new) { double(:o).as_null_object }
        subject
      end
    end

    context ProconBypassMan::RemotePbmAction::REBOOT_OS do
      let(:action) { ProconBypassMan::RemotePbmAction::REBOOT_OS }

      it do
        expect(ProconBypassMan::RemotePbmAction::RebootOsAction).to receive(:new) { double(:o).as_null_object }
        subject
      end
    end

    context 'when to raise ActionUnexpectedError' do
      let(:action) { ProconBypassMan::RemotePbmAction::REBOOT_OS }

      it do
        expect(ProconBypassMan::RemotePbmAction::RebootOsAction).to receive(:new) { raise ProconBypassMan::RemotePbmAction::ActionUnexpectedError }
        expect(ProconBypassMan::SendErrorCommand).to receive(:execute)
        subject
      end
    end
  end
end
