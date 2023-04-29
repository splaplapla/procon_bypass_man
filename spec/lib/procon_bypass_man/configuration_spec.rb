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

  describe '#current_ws_server_url' do
    let(:config) { described_class.new }
    let(:api_server) { "http://localhost:3000" }

    subject { config.current_ws_server_url }

    before do
      config.api_servers = api_server
    end

    context 'current_ws_server が nil' do
      before do
        http_client = double(:http_client)
        expect(http_client).to receive(:get) { { 'ws_server_url' => nil } }
        allow(ProconBypassMan::HttpClient).to receive(:new).with(server: api_server, path: '/api/v1/configuration') { http_client }
      end

      it 'nilを返す' do
        expect(subject).to eq(nil)
      end
    end

    context 'current_ws_server が not nil' do
      context '/api/v1/configuration へのリクエストのレスポンスがnilのとき' do
        before do
          http_client = double(:http_client)
          expect(http_client).to receive(:get) { nil }
          allow(ProconBypassMan::HttpClient).to receive(:new).with(server: api_server, path: '/api/v1/configuration') { http_client }
        end

        it 'nilを返す' do
          expect(subject).to eq(nil)
        end
      end

      context '/api/v1/configuration へのリクエストのレスポンスがnot nilのとき' do
        context 'ws_server_urlのprotocolがhttp' do
          before do
            http_client = double(:http_client)
            expect(http_client).to receive(:get) { { 'ws_server_url' => 'http://example.com/websocket' } }
            allow(ProconBypassMan::HttpClient).to receive(:new).with(server: api_server, path: '/api/v1/configuration') { http_client }
          end

          it do
            expect(subject).to be_nil
          end
        end

        context 'ws_server_urlのprotocolがws' do
          before do
            http_client = double(:http_client)
            expect(http_client).to receive(:get) { { 'ws_server_url' => "ws://pbm-cloud.jiikko.com/websocket" } }
            allow(ProconBypassMan::HttpClient).to receive(:new).with(server: api_server, path: '/api/v1/configuration') { http_client }
          end

          it '文字列を返す' do
            expect(subject).to eq("ws://pbm-cloud.jiikko.com/websocket")
          end
        end

        context 'ws_server_urlのprotocolがwss' do
          before do
            http_client = double(:http_client)
            expect(http_client).to receive(:get) { { 'ws_server_url' => "wss://pbm-cloud.jiikko.com/websocket" } }
            allow(ProconBypassMan::HttpClient).to receive(:new).with(server: api_server, path: '/api/v1/configuration') { http_client }
          end

          it '文字列を返す' do
            expect(subject).to eq("ws://pbm-cloud.jiikko.com/websocket")
          end
        end

        context 'ws_server_urlがnot uri' do
          before do
            http_client = double(:http_client)
            expect(http_client).to receive(:get) { { 'ws_server_url' => '*****' } }
            allow(ProconBypassMan::HttpClient).to receive(:new).with(server: api_server, path: '/api/v1/configuration') { http_client }
          end

          it do
            expect(subject).to be_nil
          end
        end
      end
    end
  end
end
