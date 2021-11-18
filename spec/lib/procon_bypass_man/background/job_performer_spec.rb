require "spec_helper"

describe ProconBypassMan::Background::JobPerformer do
  it do
    args = [1]
    ProconBypassMan::Background::JobPerformer.new(
      klass: ProconBypassMan::ReportPressedButtonsJob,
      args: args,
    ).perform
  end

  context 'エラーが起きる時' do
    TestJob = Class.new do
      def self.perform
        raise RuntimeError.new("ううううううううううううううううううううう")
      end
    end

    it do
      expect(ProconBypassMan::ReportErrorJob).to receive(:perform)
      ProconBypassMan::Background::JobPerformer.new(klass: TestJob, args: []).perform
    end
  end
end
