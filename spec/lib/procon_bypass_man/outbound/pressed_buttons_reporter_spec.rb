require "spec_helper"

describe ProconBypassMan::PressedButtonsReporter do
  describe '.report' do
    it do
      http_response = double(:http_response).as_null_object
      expect(http_response).to receive(:code) { "200" }
      expect_any_instance_of(Net::HTTP).to receive(:post) { http_response }
      expect { described_class.report(body: {}) }.not_to raise_error
    end
  end
end
