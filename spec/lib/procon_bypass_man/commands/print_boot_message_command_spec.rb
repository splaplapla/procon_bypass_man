require "spec_helper"

describe ProconBypassMan::PrintBootMessageCommand do
  describe '.execute' do
    it do
      expect { described_class.execute }.to change { ProconBypassMan::Outbound::Worker.queue.size }.by(2)
    end
  end
end
