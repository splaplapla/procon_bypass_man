require "spec_helper"

describe ProconBypassMan::PressedButtonsReporter do
  before do
    described_class.reset!
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
      expect { described_class.report(body: {}) }.not_to raise_error
    end
  end
end
