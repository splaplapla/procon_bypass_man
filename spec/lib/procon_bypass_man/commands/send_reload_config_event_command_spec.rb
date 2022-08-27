require "spec_helper"

describe ProconBypassMan::SendReloadConfigEventCommand do
  include_context 'enable_job_queue_on_drb'

  describe '.execute' do
    it do
      expect(described_class.execute).not_to be_nil
    end

    it do
      described_class.execute
      if ProconBypassMan::Background::JobQueue.size > 0
        job = ProconBypassMan::Background::JobQueue.pop
        expect(job).to include(args: instance_of(Array), job_class: 'ProconBypassMan::ReportReloadConfigJob')
      else
        raise "おかしい"
      end
    end
  end
end

