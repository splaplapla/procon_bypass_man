require "spec_helper"

describe ProconBypassMan::Websocket::PbmJobClient do
  xdescribe '.run' do
  end

  xdescribe '.start!' do
  end

  describe '.validate_and_run_remote_pbm_action' do
    subject { described_class.validate_and_run_remote_pbm_action(data: data) }

    context 'validation errorが起きるとき' do
      let(:data) { { "message" => {"action"=>"unknown", "status"=>"queued", "uuid"=>"20f27b6a-f727-4f8e-819b-bb60035d2ebc", "created_at"=>"2021-11-25T00:40:21.705+09:00"} } }

      it do
        expect(ProconBypassMan::RunRemotePbmActionDispatchCommand).not_to receive(:execute)
        expect(ProconBypassMan::SendErrorCommand).to receive(:execute).with(error: ProconBypassMan::RemotePbmActionObject::NonSupportAction)
        subject
      end
    end

    context 'valid' do
      context 'action is reboot_os' do
        let(:data) { { "message" => {"action"=>"reboot_os", "status"=>"queued", "uuid"=>"20f27b6a-f727-4f8e-819b-bb60035d2ebc", "created_at"=>"2021-11-25T00:40:21.705+09:00"} } }

        it do
          expect(ProconBypassMan::RunRemotePbmActionDispatchCommand).to receive(:execute)
          subject
        end
      end

      context 'action is change_pbm_version' do
        let(:data) { { "message" => {"action"=>"change_pbm_version", "status"=>"queued", "uuid"=>"20f27b6a-f727-4f8e-819b-bb60035d2ebc", "created_at"=>"2021-11-25T00:40:21.705+09:00"} } }

        it do
          expect(ProconBypassMan::RunRemotePbmActionDispatchCommand).to receive(:execute)
          subject
        end
      end

      context 'action is restore_pbm_setting' do
        let(:data) { { "message" => {"action"=>"restore_pbm_setting", "status"=>"queued", "uuid"=>"20f27b6a-f727-4f8e-819b-bb60035d2ebc", "created_at"=>"2021-11-25T00:40:21.705+09:00"} } }

        it do
          expect(ProconBypassMan::RunRemotePbmActionDispatchCommand).to receive(:execute)
          subject
        end
      end
    end
  end
end
