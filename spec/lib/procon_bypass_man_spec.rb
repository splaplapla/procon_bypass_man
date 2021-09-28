require "spec_helper"

describe ProconBypassMan do
  describe '.logger' do
    it do
      expect(described_class.logger).not_to be_nil
    end
  end

  describe '.cache' do
    it do
      expect(ProconBypassMan.respond_to?(:cache)).to eq(true)
    end
  end
end
