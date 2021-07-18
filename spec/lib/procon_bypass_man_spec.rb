require "spec_helper"

describe ProconBypassMan do
  describe '.logger' do
    it do
      expect(described_class.logger).not_to be_nil
    end
  end
end
