require "spec_helper"

describe ProconBypassMan::ProconDisplay::HttpRequest do
  describe '.parse' do
    subject { described_class.parse(io) }

    context 'ヘッダーがモリモリ' do
      let(:io) { StringIO.new(raw_http_request) }
      let(:raw_http_request) do
        <<~EOH
GET /health_check HTTP/1.1
Host: example.com
user-agent: curl/7.79.1
accept: */*

        EOH
      end

      it do
        expect(subject.to_hash).to eq({ "PATH" => "/health_check" })
      end
    end

    context 'シンプル' do
      let(:io) { StringIO.new(raw_http_request) }
      let(:raw_http_request) do
        <<~EOH
GET / HTTP/1.1

        EOH
      end

      it do
        expect(subject.path).to eq("/")
      end

      it do
        expect(subject.to_hash).to eq({ "PATH" => "/" })
      end
    end
  end
end
