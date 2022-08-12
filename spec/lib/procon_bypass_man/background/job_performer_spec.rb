require "spec_helper"

describe ProconBypassMan::Background::JobPerformer do
  it do
    expect {
      ProconBypassMan::Background::JobPerformer.new(
        klass: ProconBypassMan::ReportPressedButtonsJob,
        args: [1],
      ).perform
    }.not_to raise_error
  end

  context 'エラーが起きる時' do
    let(:test_job) do
      Class.new do
        def self.perform
          raise RuntimeError
        end
      end
    end

    it do
      expect(ProconBypassMan::ReportErrorJob).not_to receive(:perform)
      expect {
        ProconBypassMan::Background::JobPerformer.new(klass: test_job, args: []).perform
      }.to raise_error(RuntimeError)
    end
  end
end
