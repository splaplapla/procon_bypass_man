require "spec_helper"

describe ProconBypassMan::PrintBootMessageCommand do
  before do
    allow(ProconBypassMan::Background::JobQueue).to receive(:enable?) { true }
    ProconBypassMan::Background::JobQueue.start!
  end

  after do
    ProconBypassMan::Background::JobQueue.shutdown
  end

  describe ProconBypassMan::PrintBootMessageCommand::BootMessage do
    let(:bm) { described_class.new }

    describe '#to_s' do
      subject { bm.to_s }

      it do
        expect(bm.to_s).to be_a(String)
      end
    end

    describe '#to_hash' do
      subject { bm.to_hash }

      it do
        expect(bm.to_hash).to be_a(Hash)
      end

      context 'ProconBypassMan.rootが/tmp' do
        it do
          allow(ProconBypassMan).to receive(:root) { '/tmp' }
          expect(subject[:use_pbmenv]).to eq(false)
        end
      end

      context 'ProconBypassMan.rootが/usr/share/pbm' do
        it do
          allow(ProconBypassMan).to receive(:device_id) # ProconBypassMan.root以下に対して書き込みしてしまうのでワークアラウンド
          allow(ProconBypassMan).to receive(:root) { '/usr/share/pbm' }
          expect(subject[:use_pbmenv]).to eq(true)
        end
      end
    end
  end

  describe '.execute' do
    it do
      expect { described_class.execute }.to change { ProconBypassMan::Background::JobQueue.size }.by(1)
    end

    it do
      described_class.execute
      job = ProconBypassMan::Background::JobQueue.pop
      expect(job[:job_class]).to eq('ProconBypassMan::ReportBootJob')
      expect(job[:args]).to be_a(Array)
      expect(job[:args][0]).to be_a(Hash)
    end
  end
end
