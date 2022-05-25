require "spec_helper"

describe ProconBypassMan::ProconDisplay::HttpResponse do
  describe '#to_s' do
    subject { described_class.new(body, status: status).to_s }

    context 'provide { a: 2 } and 200' do
      let(:body) { { a: 2 } }
      let(:status) { 200 }

      it do
        expect(subject).to eq <<~EOH
          HTTP/1.1 200
          Content-Length: 7
          Content-Type: text/json
          Connection: close

          #{body.to_json}
        EOH
      end
    end

    context 'provide {} and 404' do
      let(:body) { {} }
      let(:status) { 404 }

      it do
        expect(subject).to eq <<~EOH
          HTTP/1.1 404
          Content-Length: 2
          Content-Type: text/json
          Connection: close

          {}
        EOH
      end
    end

    context 'provide {} and 200' do
      let(:body) { {} }
      let(:status) { 200 }

      it do
        expect(subject).to eq <<~EOH
          HTTP/1.1 200
          Content-Length: 2
          Content-Type: text/json
          Connection: close

          {}
        EOH
      end
    end

    context 'provide nil and 404' do
      let(:body) { nil }
      let(:status) { 200 }

      it do
        expect(subject).to eq <<~EOH
          HTTP/1.1 200
          Content-Length: 0
          Content-Type: text/json
          Connection: close


        EOH
      end
    end
  end
end
