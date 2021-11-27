require "spec_helper"

describe ProconBypassMan::FetchAndRunRemotePbmActionJob do
  describe '.perform' do
    subject { described_class.perform }

    context 'レスポンスがゼロのとき' do
      before do
        http_client = double(:http_client)
        expect(http_client).to receive(:get) { [] }
        expect(ProconBypassMan::HttpClient).to receive(:new) { http_client }
      end

      it do
        expect { subject }.not_to raise_error
      end
    end

    context 'レスポンスがあるとき' do
      before do
        http_client = double(:http_client)
        expect(http_client).to receive(:get) { response }
        expect(ProconBypassMan::HttpClient).to receive(:new) { http_client }
      end

      context 'validation errorが起きるとき' do
        let(:response) { [{}] }

        it 'エラー通知すること' do
          expect(ProconBypassMan::SendErrorCommand).to receive(:execute)
          expect { subject }.not_to raise_error
        end
      end

      context 'validなとき' do
        let(:response) { [{ "action" => "reboot_pbm", "uuid" => "a", "status" => "foo" }] }

        it do
          expect(ProconBypassMan::RunRemotePbmActionDispatchCommand).to receive(:execute).with(action: "reboot_pbm", uuid: "a")
          subject
        end
      end
    end
  end
end
