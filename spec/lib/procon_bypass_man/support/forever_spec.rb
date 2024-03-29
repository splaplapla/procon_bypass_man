require "spec_helper"

describe ProconBypassMan::Forever do
  let(:instance) { described_class.new }

  describe '#work_one' do
    let(:block) { double(:block) }

    subject { instance.work_one(callable: block) }

    it do
      expect(block).to receive(:call)
      thread, _watchdog = subject
      thread.join
    end
  end

  describe '#wait_and_kill_if_outdated' do
    let(:thread) { double(:thread) }
    let(:watchdog) { ProconBypassMan::Watchdog.new }

    subject { instance.wait_and_kill_if_outdated(thread, watchdog) }

    before do
      allow(watchdog).to receive(:outdated?) { true }
      thread.as_null_object
    end

    context 'when outdated' do
      it 'should kill the thread' do
        expect(thread).to receive(:kill)
        subject
      end

      it 'refresh Watchdog' do
        expect(watchdog).to receive(:active!)
        subject
      end
    end
  end
end
