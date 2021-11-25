require "spec_helper"

describe ProconBypassMan::HttpClient do
  describe '#get' do
    before do
      double(:response).tap do |response|
        expect(response).to receive(:body) { { a: 1 }.to_json }
        expect(response).to receive(:code) { "200" }
        expect_any_instance_of(Net::HTTP).to receive(:get) { response }
      end
    end

    it do
      pool = ProconBypassMan::Background::ServerPool.new(servers: ["http://localhost:3000", "http://localhost:4000"])
      expect(described_class.new(path: "/", pool_server: pool).get).to eq("a" => 1)
    end
  end

  describe '#post' do
    before do
      double(:response).tap do |response|
        expect(response).to receive(:body) { { a: 1 }.to_json }
        expect(response).to receive(:code) { "200" }
        expect_any_instance_of(Net::HTTP).to receive(:post) { response }
      end
    end

    it do
      pool = ProconBypassMan::Background::ServerPool.new(servers: ["http://localhost:3000", "http://localhost:4000"])
      expect(
        described_class.new(path: "/", pool_server: pool).post(body: {}, event_type: :a)
      ).to eq("a" => 1)
    end
  end
end
