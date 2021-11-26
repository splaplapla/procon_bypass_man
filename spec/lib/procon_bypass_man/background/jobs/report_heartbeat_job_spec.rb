require "spec_helper"

describe ProconBypassMan::ReportHeartbeatJob do
  let(:post_body) { "hoge" }

  subject { described_class.perform(post_body) }

  it do
    http_client = double(:http_client)
    expect(http_client).to receive(:post).with(body: post_body, event_type: :heartbeat)
    expect(ProconBypassMan::HttpClient).to receive(:new) { http_client }
    subject
  end
end
