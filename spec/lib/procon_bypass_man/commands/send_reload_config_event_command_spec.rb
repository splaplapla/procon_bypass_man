require "spec_helper"

describe ProconBypassMan::SendReloadConfigEventCommand do
  describe '.execute' do
    it do
      expect(described_class.execute).not_to be_nil
    end

    it do
      described_class.execute
      if ProconBypassMan::Background::JobRunner.queue.size > 0
        job = ProconBypassMan::Background::JobRunner.queue.pop
        expect(job).to include(args: instance_of(Array), reporter_class: ProconBypassMan::ReportReloadConfigJob)
      else
        raise "おかしい"
      end
    end
  end
end

