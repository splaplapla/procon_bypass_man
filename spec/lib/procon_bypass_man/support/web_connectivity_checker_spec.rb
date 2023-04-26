require "spec_helper"

RSpec.describe ProconBypassMan::WebConnectivityChecker do
  describe '#to_s' do
    context 'when url is nil' do
      it 'returns "DISABLE"' do
        checker = ProconBypassMan::WebConnectivityChecker.new(nil, nil)
        expect(checker.to_s).to eq('DISABLE')
      end
    end

    context 'when url is alive' do
      it 'returns "ENABLE (url)"' do
        checker = ProconBypassMan::WebConnectivityChecker.new('https://www.example.com', 'hoge')

        http_double = instance_double('Net::HTTP')
        allow(Net::HTTP).to receive(:start).and_yield(http_double)
        allow(http_double).to receive(:request).and_return(Net::HTTPSuccess.new(1.0, 200, 'OK'))

        expect(checker.to_s).to eq('ENABLE (https://www.example.com, hoge)')
      end
    end

    context 'when url is unreachable' do
      it 'returns "UNREACHABLE (url)"' do
        checker = ProconBypassMan::WebConnectivityChecker.new('https://www.unreachable-url.com', 'hoge')

        http_double = instance_double('Net::HTTP')
        allow(Net::HTTP).to receive(:start).and_yield(http_double)
        allow(http_double).to receive(:request).and_return(Net::HTTPNotFound.new(1.0, 404, 'Not Found'))

        expect(checker.to_s).to eq('UNREACHABLE (https://www.unreachable-url.com)')
      end
    end
  end
end
