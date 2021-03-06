require "spec_helper"

describe ProconBypassMan::ProconDisplay::ServerApp do
  describe '#call' do
    subject { described_class.new(env).call  }


    context '/input' do
      let(:env) { { "PATH" => "/input" } }

      context 'has value status' do
        before do
          ProconBypassMan::ProconDisplay::Status.instance.current = { a: 123 }
        end

        it do
          expect(subject).to eq <<~EOH
          HTTP/1.1 200
          Content-Length: 9
          Content-Type: text/json
          Access-Control-Allow-Origin: *
          Access-Control-Allow-Methods: GET
          Access-Control-Allow-Private-Network：true
          Connection: close

          #{{a: 123 }.to_json}
          EOH
        end
      end

      context 'empty status' do
        before do
          ProconBypassMan::ProconDisplay::Status.instance.current = nil
        end

        it do
          expect(subject).to eq <<~EOH
          HTTP/1.1 200
          Content-Length: 2
          Content-Type: text/json
          Access-Control-Allow-Origin: *
          Access-Control-Allow-Methods: GET
          Access-Control-Allow-Private-Network：true
          Connection: close

          {}
          EOH
        end
      end
    end

    context '/foo' do
      let(:env) { { "PATH" => "/foo" } }

      it do
        expect(subject).to eq <<~EOH
          HTTP/1.1 404
          Content-Length: 0
          Content-Type: text/json
          Access-Control-Allow-Origin: *
          Access-Control-Allow-Methods: GET
          Access-Control-Allow-Private-Network：true
          Connection: close


        EOH
      end
    end
  end
end
