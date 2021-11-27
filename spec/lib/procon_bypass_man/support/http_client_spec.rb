require "spec_helper"

describe ProconBypassMan::HttpClient do
  describe '#get' do
    before do
      double(:response).tap do |response|
        allow(response).to receive(:body) { { a: 1 }.to_json }
        allow(response).to receive(:code) { "200" }
        allow_any_instance_of(Net::HTTP).to receive(:get) { response }
      end
    end

    context 'server_poolに値があるとき' do
      let(:pool) { ProconBypassMan::ServerPool.new(servers: ["http://localhost:3000", "http://localhost:4000"]) }

      it do
        expect(described_class.new(path: "/", server_pool: pool).get).to eq("a" => 1)
      end
    end

    context 'server_poolが空のとき' do
      let(:pool) { ProconBypassMan::ServerPool.new(servers: []) }

      it do
        expect(described_class.new(path: "/", server_pool: pool).get).to eq(nil)
      end
    end
  end

  describe '#post' do
    before do
      double(:response).tap do |response|
        allow(response).to receive(:body) { { a: 1 }.to_json }
        allow(response).to receive(:code) { "200" }
        allow_any_instance_of(Net::HTTP).to receive(:post) { response }
      end
    end

    context 'server_poolに値があるとき' do
      let(:pool) { ProconBypassMan::ServerPool.new(servers: ["http://localhost:3000", "http://localhost:4000"]) }

      it do
        expect(
          described_class.new(path: "/", server_pool: pool).post(request_body: {})
        ).to eq("a" => 1)
      end
    end

    context 'server_poolが空のとき' do
      let(:pool) { ProconBypassMan::ServerPool.new(servers: []) }

      it do
        expect(described_class.new(path: "/", server_pool: pool).post(request_body: {})).to eq(nil)
      end
    end
  end

  describe '#put' do
    before do
      double(:response).tap do |response|
        allow(response).to receive(:body) { { a: 1 }.to_json }
        allow(response).to receive(:code) { "200" }
        allow_any_instance_of(Net::HTTP).to receive(:post) { response }
      end
    end

    context 'server_poolに値があるとき' do
      let(:pool) { ProconBypassMan::ServerPool.new(servers: ["http://localhost:3000", "http://localhost:4000"]) }

      it do
        expect(
          described_class.new(path: "/", server_pool: pool).post(request_body: {})
        ).to eq("a" => 1)
      end
    end

    context 'server_poolが空のとき' do
      let(:pool) { ProconBypassMan::ServerPool.new(servers: []) }

      it do
        expect(described_class.new(path: "/", server_pool: pool).post(request_body: {})).to eq(nil)
      end
    end
  end
end
