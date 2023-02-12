require "spec_helper"

describe ProconBypassMan::RemoteMacroSender do
  before do
    allow(ProconBypassMan::RemoteMacro::QueueOverProcess).to receive(:enable?) { true }
    ProconBypassMan::RemoteMacro::QueueOverProcess.start!
  end

  after do
    ProconBypassMan::RemoteMacro::QueueOverProcess.shutdown
  end

  describe '.execute' do
    let(:name) { "a" }
    let(:uuid) { "b" }
    let(:steps) { "c" }

    subject { described_class.execute(name: name, uuid: uuid, steps: steps, type: nil) }

    it do
      subject
      expect(ProconBypassMan::RemoteMacro::QueueOverProcess.pop).not_to be_nil
    end
  end
end
