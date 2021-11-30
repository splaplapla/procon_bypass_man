require "spec_helper"

describe ProconBypassMan::SendErrorCommand do
  before do
    allow(ProconBypassMan.config).to receive(:server_pool) { ProconBypassMan::ServerPool.new(servers: []) }
  end

  describe '.execute' do
    it do
      expect(ProconBypassMan::ReportErrorJob).to receive(:perform)
      described_class.execute(error: "a")
    end
  end
end
