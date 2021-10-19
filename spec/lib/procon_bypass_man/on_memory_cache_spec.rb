require "spec_helper"

describe ProconBypassMan::OnMemoryCache do
  describe '#fetch' do
    it do
      cache = ProconBypassMan::OnMemoryCache.new
      Timecop.freeze(Time.parse("2011-11-11 10:00:00 +09:00")) do
        expect(cache.fetch(key: "a", expires_in: 3) { "value_of_a" }).to eq("value_of_a")
        expect(cache.fetch(key: "a", expires_in: 3) { "changed" }).to eq("value_of_a")
      end
      Timecop.freeze(Time.parse("2011-11-11 10:00:02 +09:00")) do
        expect(cache.fetch(key: "a", expires_in: 3) { "changed" }).to eq("value_of_a")
      end
      Timecop.freeze(Time.parse("2011-11-11 10:00:04 +09:00")) do
        expect(cache.fetch(key: "a", expires_in: 3) { "changed" }).to eq("changed")
      end
    end
  end
end
