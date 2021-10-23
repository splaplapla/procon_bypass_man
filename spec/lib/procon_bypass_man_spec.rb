require "spec_helper"

describe ProconBypassMan do
  describe '.logger' do
    it do
      expect(described_class.logger).not_to be_nil
    end
  end

  describe '.cache' do
    it do
      expect(described_class.cache.respond_to?(:fetch)).to eq(true)
    end
  end

  describe 'internal_api_servers' do
    it do
      expect(described_class.internal_api_servers).to be_a(Array)
    end
  end
end
