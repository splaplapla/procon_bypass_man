require "spec_helper"

describe ProconBypassMan::BootMessage do
  let(:bm) { described_class.new }
  describe '#to_s' do
    it do
      expect(bm.to_s).to be_a(String)
    end
  end

  describe '#to_hash' do
    it do
      expect(bm.to_hash).to be_a(Hash)
    end
  end
end
