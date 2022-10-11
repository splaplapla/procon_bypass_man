require "spec_helper"

describe ProconBypassMan::PostCompletedRemoteMacroJob do
  describe '.re_enqueue_if_failed' do
    it do
      expect(described_class.re_enqueue_if_failed).to be(true)
    end
  end

  describe '.perform' do
    before do
      ProconBypassMan.configure do |config|
        config.api_servers = ["http://localhost:3000"]
      end
    end

    it do
      http_response = double(:http_response).as_null_object
      expect(http_response).to receive(:code) { "200" }
      expect_any_instance_of(Net::HTTP).to receive(:post) { http_response }
      expect { described_class.perform({}) }.not_to raise_error
    end

    context 'エラーが起きる時' do
      before do
        allow(ProconBypassMan).to receive(:logger) { double(:logger).as_null_object }
      end

      it do
        allow(ProconBypassMan::HttpClient::HttpRequest::Post).to receive(:request!) { raise "hoge" }
        expect { described_class.perform({}) }.to raise_error(RuntimeError)
      end
    end
  end
end

