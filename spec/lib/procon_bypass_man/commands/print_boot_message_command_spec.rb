require "spec_helper"

describe ProconBypassMan::PrintBootMessageCommand do
  describe ProconBypassMan::PrintBootMessageCommand::BootMessage do
    let(:bm) { described_class.new }
    describe '#to_s' do
      it do
        expect(bm.to_s).to be_a(String)
      end
    end

    describe '#to_hash' do
      it do
        expect(bm.to_hash).to be_a(Hash)
      end
    end
  end

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
      expect(job[:reporter_class]).to eq(ProconBypassMan::ReportLoadConfigJob)
      expect(job[:args]).to be_a(Array)
    end
  end
end
