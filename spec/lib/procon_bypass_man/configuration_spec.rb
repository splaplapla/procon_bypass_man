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

  describe '#enable_reporting_pressed_buttons' do
    let(:config) { described_class.new }
    it 'default false' do
      expect(config.enable_reporting_pressed_buttons).to eq(false)
    end

    it do
      config.enable_reporting_pressed_buttons = true
      expect(config.enable_reporting_pressed_buttons).to eq(true)
    end
  end

  describe '#enable_home_led_on_connect' do
    let(:config) { described_class.new }
    subject { config.enable_home_led_on_connect }

    it 'default true' do
      expect(subject).to eq(true)
    end

    it do
      config.enable_home_led_on_connect = true
      expect(subject).to eq(true)
    end

    it do
      config.enable_home_led_on_connect = false
      expect(subject).to eq(false)
    end
  end

  describe '#has_api_server?' do
    let(:config) { described_class.new }
    context 'when has api_server' do
      it do
        config.api_servers=("foo")
        expect(config.has_api_server?).to eq(true)
      end
    end

    it 'default false' do
      expect(config.has_api_server?).to eq(false)
    end
  end

  describe '#bypass_mode=' do
    let(:config) { described_class.new }

    it do
      config.bypass_mode = { mode: :normal, gadget_to_procon_interval: 0.1 }
      expect(config.bypass_mode.mode).to eq(:normal)
      expect(config.bypass_mode.gadget_to_procon_interval).to eq(0.1)
    end
  end
end
