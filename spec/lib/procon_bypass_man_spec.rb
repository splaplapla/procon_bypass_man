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

  describe 'class methods' do
    [ :logger=,
      :logger,
      :enable_critical_error_logging!,
      :error_logger,
      :pid_path,
      :root,
      :root=,
      :api_server=,
      :api_server,
      :digest_path,
    ].each do |me|
      it "has #{me} method" do
        expect(described_class.respond_to?(me)).to eq(true)
      end
    end
  end
end
