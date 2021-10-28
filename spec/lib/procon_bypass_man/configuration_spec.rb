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
end
