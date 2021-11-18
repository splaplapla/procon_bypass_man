require "spec_helper"

describe ProconBypassMan::Background::JobRunner do
  describe ProconBypassMan::Background::JobRunner::Job do
    it do
      args = [1]
      ProconBypassMan::Background::JobRunner::Job.new(
        klass: ProconBypassMan::ReportPressedButtonsJob,
        args: args,
      ).perform
    end
  end

  describe '.perform_async' do
    it do
      ProconBypassMan::ReportErrorJob.perform_async("a")
      job = ProconBypassMan::Background::JobRunner.queue.pop
      expect(job).to eq(:args=>["a"], :reporter_class=>ProconBypassMan::ReportErrorJob)
    end
  end

  describe '.push' do
    it do
      class Result < Struct.new(:stats); end
      reporter_class = Class.new do
        def self.report(*); Result.new(true); end
      end
      expect {
        ProconBypassMan::Background::JobRunner.push({
          reporter_class: reporter_class,
          body: {},
        })
      }.not_to raise_error
    end
    context '上限までenqueueしたとき' do
      let(:dummy_queue) { [] }
      before do
        101.times { dummy_queue << true }
        allow(ProconBypassMan::Background::JobRunner).to receive(:queue) { dummy_queue }
      end
      it do
        expect(ProconBypassMan::Background::JobRunner.push(true)).to be_nil
      end
    end
  end
end
