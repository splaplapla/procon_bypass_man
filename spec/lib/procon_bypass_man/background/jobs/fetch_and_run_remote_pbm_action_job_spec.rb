require "spec_helper"

describe ProconBypassMan::FetchAndRunRemotePbmActionJob do
  describe '.perform' do
    context 'レスポンスがゼロのとき' do
      before do
        http_client = double(:http_client)
        expect(http_client).to receive(:get) { [] }
        expect(ProconBypassMan::HttpClient).to receive(:new) { http_client }
      end

      it do
        expect { described_class.perform }.not_to raise_error
      end
    end

    context 'レスポンスがあるとき' do
      before do
        http_client = double(:http_client)
        expect(http_client).to receive(:get) { response_list }
        expect(ProconBypassMan::HttpClient).to receive(:new) { http_client }
      end

      context 'validation errorが起きるとき' do
        let(:response_list) { [{}] }

        it 'エラー通知すること' do
          expect(ProconBypassMan::SendErrorCommand).to receive(:execute)
          expect { described_class.perform }.not_to raise_error
        end
      end
    end
  end
end
