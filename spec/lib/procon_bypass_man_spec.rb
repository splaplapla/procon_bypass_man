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
      :session_id,
      :device_id,
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
      :verbose_bypass_log,
      :verbose_bypass_log=,
      :digest_path,
      :raw_setting,
      :raw_setting=,
      :enable_reporting_pressed_buttons,
      :enable_reporting_pressed_buttons=,
      :never_exit_accidentally,
      :never_exit_accidentally=,
    ].each do |me|
      it "has config.#{me} method" do
        expect(described_class.config.respond_to?(me)).to eq(true)
      end
    end
  end

  describe '.run' do
    describe 'error handling' do
      subject { described_class.run }

      before do
        allow(ProconBypassMan::ButtonsSettingConfiguration::Loader).to receive(:load)
        allow(ProconBypassMan::ConnectDeviceCommand).to receive(:execute!)
      end

      context 'エラーが起きない' do
        before do
          allow(ProconBypassMan::Runner).to receive(:new) { double(:a).as_null_object }
        end

        it do
          expect { subject }.not_to raise_error
        end

        it do
          subject
          expect(ProconBypassMan::DeviceStatus.current).to eq(ProconBypassMan::DeviceStatus::RUNNING)
        end
      end

      context 'NotFoundRequiredFilesErrorが起きるとき' do
        before do
          allow(ProconBypassMan::ConnectDeviceCommand).to receive(:execute!) { raise ProconBypassMan::NotFoundRequiredFilesError }
        end

        it do
          expect{ subject }.to raise_error(SystemExit)
        end
      end

      context 'CouldNotLoadConfigErrorが起きるとき' do
        before do
          allow(ProconBypassMan::Runner).to receive(:new) { raise ProconBypassMan::CouldNotLoadConfigError }
        end

        it do
          expect{ subject }.to raise_error(SystemExit)
          expect(ProconBypassMan::DeviceStatus.current).to eq(ProconBypassMan::DeviceStatus::SETTING_SYNTAX_ERROR_AND_SHUTDOWN)
        end
      end

      context 'NotFoundProconErrorが起きるとき' do
        before do
          allow(ProconBypassMan::Runner).to receive(:new) { raise ProconBypassMan::DeviceConnector::NotFoundProconError }
        end

        it do
          expect{ subject }.to raise_error(SystemExit)
          expect(ProconBypassMan::DeviceStatus.current).to eq(ProconBypassMan::DeviceStatus::PROCON_NOT_FOUND_ERROR)
        end
      end

      context 'EternalConnectionErrorが起きるとき' do
        before do
          allow(ProconBypassMan::Runner).to receive(:new) { raise ProconBypassMan::EternalConnectionError }
        end

        it do
          expect(ProconBypassMan).to receive(:eternal_sleep)
          subject
          expect(ProconBypassMan::DeviceStatus.current).to eq(ProconBypassMan::DeviceStatus::CONNECTED_BUT_SLEEPING)
        end
      end
    end
  end
end
