require "spec_helper"

describe ProconBypassMan::ReportErrorJob do
  describe '.perform' do
    before do
      ProconBypassMan.configure do |config|
        config.api_servers = ["http://localhost:3000", "http://localhost:4000"]
      end
    end

    after do
      ProconBypassMan.configure do |config|
        config.api_servers = nil
      end
    end

    context 'provide String' do
      let(:post_body) { "hoge" }

      subject { described_class.perform(post_body) }

      it do
        http_client = double(:http_client)
        subject
      end
    end

    context 'provide Error' do
      let(:post_body) { RuntimeError.new("ffffffffff") }

      subject { described_class.perform(post_body) }

      it do
        http_client = double(:http_client)
        subject
      end
    end
  end
end
