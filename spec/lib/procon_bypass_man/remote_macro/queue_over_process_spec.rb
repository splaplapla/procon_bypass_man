require "spec_helper"

describe ProconBypassMan::RemoteMacro::QueueOverProcess do
  before do
    allow(ProconBypassMan::RemoteMacro::QueueOverProcess).to receive(:enable?) { true }
    ProconBypassMan::RemoteMacro::QueueOverProcess.start!
  end

  after do
    ProconBypassMan::RemoteMacro::QueueOverProcess.shutdown
  end

  describe '.start!' do
    subject { ProconBypassMan::RemoteMacro::QueueOverProcess.start! }

    context 'when not enable' do
      it do
        allow(ProconBypassMan.config).to receive(:enable_remote_macro?) { false }
        expect(subject).to be_a(Thread)
        ProconBypassMan::RemoteMacro::QueueOverProcess.shutdown
      end
    end

    context 'when enable' do
      before(:each) do
        allow(ProconBypassMan.config).to receive(:enable_remote_macro?) { true }
      end

      it do
        expect { subject }.not_to raise_error
        ProconBypassMan::RemoteMacro::QueueOverProcess.shutdown
      end
    end
  end

  describe 'pop, push' do
    before(:each) do
      allow(ProconBypassMan.config).to receive(:enable_remote_macro?) { true }
      ProconBypassMan::RemoteMacro::QueueOverProcess.start!
    end

    after(:each) do
      ProconBypassMan::RemoteMacro::QueueOverProcess.shutdown
    end

    before do
      require 'drb/drb'
      described_class.clear
    end

    it do
      described_class.push "a"
      expect(described_class.pop).to eq("a")
    end
  end
end
