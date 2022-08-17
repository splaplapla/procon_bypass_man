require "spec_helper"

describe ProconBypassMan::SendErrorCommand do
  describe '.execute' do
    it do
      expect(ProconBypassMan::ReportErrorJob).to receive(:perform)
      described_class.execute(error: "a")
    end
  end
end
