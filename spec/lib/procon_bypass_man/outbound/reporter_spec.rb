require "spec_helper"

describe ProconBypassMan::Reporter do
  describe '.report' do
    context 'ProconBypassMan.api_serverが設定されていない時' do
      before do
        ProconBypassMan.configure do |config|
          config.api_server = nil
        end
      end
      it do
        expect(ProconBypassMan.config.api_servers).to be_nil
        expect { described_class.report(body: {}) }.not_to raise_error
      end
    end

    context 'ProconBypassMan.api_serverが設定しているとき' do
      before do
        ProconBypassMan.configure do |config|
          config.api_servers = ["http://localhost:3000"]
        end
      end
      it do
        http_response = double(:http_response).as_null_object
        expect(http_response).to receive(:code) { "200" }
        expect_any_instance_of(Net::HTTP).to receive(:post) { http_response }
        expect { described_class.report(body: nil) }.not_to raise_error
      end
    end
  end
end
