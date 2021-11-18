require "spec_helper"

describe ProconBypassMan::ReportPressedButtonsJob do
  before do
    described_class.reset_server_pool!
  end

  describe '.report' do
    before do
      ProconBypassMan.configure do |config|
        config.api_servers = ["http://localhost:3000", "http://localhost:4000"]
      end
    end

    it do
      http_response = double(:http_response).as_null_object
      expect(http_response).to receive(:code) { "200" }
      expect_any_instance_of(Net::HTTP).to receive(:post) { http_response }
      expect { described_class.perform({}) }.not_to raise_error
    end
  end
end
