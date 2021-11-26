require "spec_helper"

describe ProconBypassMan::ReportErrorJob do
  describe '.perform' do
    let(:post_body) { "hoge" }

    subject { described_class.perform(post_body) }

    it do
      http_client = double(:http_client)
      expect(http_client).to receive(:post).with(body: post_body, event_type: :error)
      expect(ProconBypassMan::HttpClient).to receive(:new) { http_client }
      subject
    end
  end
end
