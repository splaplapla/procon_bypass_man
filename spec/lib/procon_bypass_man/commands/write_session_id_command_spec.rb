require "spec_helper"

describe ProconBypassMan::WriteSessionIdCommand do
  describe '.execute' do
    it do
      expect(described_class.execute).to be_a(String)
    end
  end
end
