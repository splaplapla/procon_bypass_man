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
      expect(described_class.config.internal_api_servers).to be_a(Array)
    end
  end

  describe 'class methods' do
    [ :logger,
      :error_logger,
      :pid_path,
      :root,
      :digest_path,
    ].each do |me|
      it "has #{me} method" do
        expect(described_class.respond_to?(me)).to eq(true)
      end
    end
  end

  describe '.configで公開しているメソッド' do
    [ :logger=,
      :logger,
      :error_logger,
      :root,
      :root=,
      :api_server=,
      :api_server,
      :verbose_bypass_log,
      :verbose_bypass_log=,
      :digest_path,
    ].each do |me|
      it "has config.#{me} method" do
        expect(described_class.config.respond_to?(me)).to eq(true)
      end
    end
  end
end
