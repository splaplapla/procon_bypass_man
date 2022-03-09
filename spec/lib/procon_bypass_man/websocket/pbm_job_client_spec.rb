require "spec_helper"

describe ProconBypassMan::Websocket::PbmJobClient do
  xdescribe '.run' do
  end

  xdescribe '.start!' do
  end

  describe '.dispatch' do
    subject { described_class.dispatch(data: data, client: nil) }

    context 'when remote_macro action' do
      let(:data) { { "message" => { "action"=>"remote_macro" } } }
      it do
        expect(described_class).to receive(:validate_and_run_remote_macro)
        subject
      end
    end

    context 'when restore_pbm_setting action' do
      let(:data) { { "message" => { "action"=>"restore_pbm_setting" } } }
      it do
        expect(described_class).to receive(:validate_and_run_remote_pbm_action)
        subject
      end
    end

    context 'when not found action' do
      let(:data) { { "message" => { "action"=>"not_found" } } }
      it do
        expect(described_class).not_to receive(:validate_and_run_remote_pbm_action)
        expect(described_class).not_to receive(:validate_and_run_remote_macro)
        subject
      end
    end
  end

  describe '.validate_and_run_remote_macro' do
    subject { described_class.validate_and_run_remote_macro(data: data) }

    context 'valid' do
      let(:data) { { "message" => {"action"=>"a", "uuid"=>"c", "steps"=>[] } } }

      it do
        expect(ProconBypassMan::RemoteMacroSender).to receive(:execute).with(action: "a", uuid: "c", steps: [])
        subject
      end
    end

    context 'invalid' do
      context 'stepsがnil' do
        let(:data) { { "message" => {"action"=>"remote_action",  "uuid"=>"20f27b6a-f727-4f8e-819b-bb60035d2ebc" } } }

        it do
          expect(ProconBypassMan::SendErrorCommand).to receive(:execute).with(error: ProconBypassMan::RemoteMacroObject::ValidationError)
          subject
        end
      end

      context 'uuidがnil' do
        let(:data) { { "message" => {"action"=>"remote_action",  "uuid"=>nil, 'steps'=>[] } } }

        it do
          expect(ProconBypassMan::SendErrorCommand).to receive(:execute).with(error: ProconBypassMan::RemoteMacroObject::MustBeNotNilError)
          subject
        end
      end
    end
  end

  describe '.validate_and_run_remote_pbm_action' do
    subject { described_class.validate_and_run_remote_pbm_action(data: data) }

    context 'invalid' do
      context '知らないaction' do
        let(:data) { { "message" => {"action"=>"unknown", "status"=>"queued", "uuid"=>"20f27b6a-f727-4f8e-819b-bb60035d2ebc", "created_at"=>"2021-11-25T00:40:21.705+09:00"} } }

        it do
          expect(ProconBypassMan::RunRemotePbmActionDispatchCommand).not_to receive(:execute)
          expect(ProconBypassMan::SendErrorCommand).to receive(:execute).with(error: ProconBypassMan::RemotePbmActionObject::NonSupportAction)
          subject
        end
      end

      context 'uuidがnil' do
        let(:data) { { "message" => {"action"=>"unknown", "status"=>"queued", "uuid"=>nil, "created_at"=>"2021-11-25T00:40:21.705+09:00"} } }

        it do
          expect(ProconBypassMan::RunRemotePbmActionDispatchCommand).not_to receive(:execute)
          expect(ProconBypassMan::SendErrorCommand).to receive(:execute).with(error: ProconBypassMan::RemotePbmActionObject::MustBeNotNilError)
          subject
        end
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
