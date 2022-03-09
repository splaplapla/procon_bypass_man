require "spec_helper"

describe ProconBypassMan::RemoteMacroSender do
  describe '.execute' do
    let(:action) { "a" }
    let(:uuid) { "b" }
    let(:steps) { "c" }

    subject { described_class.execute(action: action, uuid: uuid, steps: steps) }

    it do
      expect(subject).to eq(nil)
    end
  end
end
