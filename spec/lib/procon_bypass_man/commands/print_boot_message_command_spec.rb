require "spec_helper"

describe ProconBypassMan::PrintBootMessageCommand do
  describe '.execute' do
    it do
      expect { described_class.execute }.to change { ProconBypassMan::Background::JobRunner.queue.size }.by(2)
    end

    it do
      described_class.execute
      job = ProconBypassMan::Background::JobRunner.queue.pop
      expect(job[:reporter_class]).to eq(ProconBypassMan::ReportBootJob)
      expect(job[:args]).to be_a(Array)
      expect(job[:args][0]).to be_a(Hash)

      job = ProconBypassMan::Background::JobRunner.queue.pop
      expect(job[:reporter_class]).to eq(ProconBypassMan::ReportBootJob)
      expect(job[:args]).to be_a(Array)
    end
  end
end
