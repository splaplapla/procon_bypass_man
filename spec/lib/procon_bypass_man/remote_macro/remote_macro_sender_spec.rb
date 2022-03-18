require "spec_helper"

describe ProconBypassMan::RemoteMacroSender do
  describe '.execute' do
    let(:name) { "a" }
    let(:uuid) { "b" }
    let(:steps) { "c" }

    subject { described_class.execute(name: name, uuid: uuid, steps: steps) }

    it do
      expect(subject).to eq(nil)
    end
  end
end
