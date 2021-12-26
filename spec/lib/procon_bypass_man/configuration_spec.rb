require "spec_helper"

describe ProconBypassMan::Configuration do
  describe '.configure' do
    it do
      ProconBypassMan.configure do |config|
        config.root = "/tmp"
        config.logger = Logger.new("#{ProconBypassMan.root}/app.log", 5, 1024 * 1024 * 10)
        config.logger.level = :debug
        config.enable_critical_error_logging = true
      end

      expect(ProconBypassMan.config.enable_critical_error_logging).to eq(true)
      expect(ProconBypassMan.config.root).to eq("/tmp")
      expect(ProconBypassMan.logger).to be_a(Logger)
    end
  end

  describe '#verbose_bypass_log' do
    it do
      expect(described_class.new.verbose_bypass_log).to eq(false)
    end
    it do
      config = described_class.new
      config.verbose_bypass_log = true
      expect(config.verbose_bypass_log).to eq(true)
    end
  end

  describe '#api_servers=' do
    it do
      config = described_class.new
      config.api_servers = ["http://hoge.com"]
      expect(config.api_servers).to eq(["http://hoge.com"])
    end

    it do
      config = described_class.new
      config.api_servers = "http://hoge.com"
      expect(config.api_servers).to eq(["http://hoge.com"])
    end
  end

  describe '#current_ws_server' do
    let(:config) { described_class.new }
    subject { config.current_ws_server }
    context 'http://localhost:3000をセットするとき' do
      it do
        config.api_servers = ["http://localhost:3000"]
        expect(subject).to eq("ws://localhost:3000")
      end
    end

    context 'https://foo.herokuapp.comをセットするとき' do
      it do
        config.api_servers = ["https://foo.herokuapp.com"]
        expect(subject).to eq("ws://foo.herokuapp.com")
      end
    end
  end
end
