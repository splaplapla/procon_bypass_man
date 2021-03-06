require "spec_helper"

describe ProconBypassMan::RemoteMacroSender do
  describe '.execute' do
    let(:name) { "a" }
    let(:uuid) { "b" }
    let(:steps) { "c" }

    before do
      ProconBypassMan::RemoteMacro::QueueOverProcess.start!
    end

    after do
      ProconBypassMan::RemoteMacro::QueueOverProcess.shutdown
    end

    subject { described_class.execute(name: name, uuid: uuid, steps: steps) }

    it do
      subject
      expect(ProconBypassMan::RemoteMacro::QueueOverProcess.pop).not_to be_nil
    end
  end
end
