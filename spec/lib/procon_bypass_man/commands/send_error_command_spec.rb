require "spec_helper"

describe ProconBypassMan::SendErrorCommand do
  describe '.execute' do
    it do
      expect(described_class.execute(error: "a")).not_to be_nil
    end
  end
end
