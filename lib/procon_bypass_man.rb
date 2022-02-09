require "logger"
require 'yaml'
require "json"
require "net/http"
require "fileutils"
require "securerandom"
require 'em/pure_ruby'
require "action_cable_client"
require "ext/em_pure_ruby"
require "ext/module"

require_relative "procon_bypass_man/version"
require_relative "procon_bypass_man/remote_pbm_action"
require_relative "procon_bypass_man/support/signal_handler"
require_relative "procon_bypass_man/support/callbacks"
require_relative "procon_bypass_man/support/yaml_writer"
require_relative "procon_bypass_man/support/safe_timeout"
require_relative "procon_bypass_man/support/compress_array"
require_relative "procon_bypass_man/support/uptime"
require_relative "procon_bypass_man/support/on_memory_cache"
require_relative "procon_bypass_man/support/http_client"
require_relative "procon_bypass_man/support/report_http_client"
require_relative "procon_bypass_man/support/update_remote_pbm_action_status_http_client"
require_relative "procon_bypass_man/support/send_device_stats_http_client"
require_relative "procon_bypass_man/support/server_pool"
require_relative "procon_bypass_man/background"
require_relative "procon_bypass_man/commands"
require_relative "procon_bypass_man/bypass"
require_relative "procon_bypass_man/domains"
require_relative "procon_bypass_man/device_connector"
require_relative "procon_bypass_man/device_status"
require_relative "procon_bypass_man/runner"
require_relative "procon_bypass_man/processor"
require_relative "procon_bypass_man/configuration"
require_relative "procon_bypass_man/buttons_setting_configuration"
require_relative "procon_bypass_man/procon"
require_relative "procon_bypass_man/procon/button"
require_relative "procon_bypass_man/procon/value_objects/analog_stick"
require_relative "procon_bypass_man/procon/value_objects/procon_reader"
require_relative "procon_bypass_man/procon/analog_stick_cap"
require_relative "procon_bypass_man/remote_pbm_action/value_objects/remote_pbm_action_object"
require_relative "procon_bypass_man/scheduler"
require_relative "procon_bypass_man/plugins"
require_relative "procon_bypass_man/websocket/pbm_job_client"

STDOUT.sync = true
Thread.abort_on_exception = true

module ProconBypassMan
  extend ProconBypassMan::Configuration::ClassMethods

  class CouldNotLoadConfigError < StandardError; end
  class NotFoundProconError < StandardError; end
  class GracefulShutdown < StandardError; end
  class ConnectionError < StandardError; end
  class FirstConnectionError < ConnectionError; end
  class EternalConnectionError < ConnectionError; end

  # @return [void]
  def self.run(setting_path: nil)
    ProconBypassMan::Scheduler.start!
    ProconBypassMan::Background::JobRunner.start!
    ProconBypassMan::Websocket::PbmJobClient.start!

    ProconBypassMan::PrintMessageCommand.execute(text: "PBMを起動しています")
    ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting_path)
    initialize_pbm
    gadget, procon = ProconBypassMan::ConnectDeviceCommand.execute!
    Runner.new(gadget: gadget, procon: procon).run
  rescue ProconBypassMan::CouldNotLoadConfigError
    ProconBypassMan::SendErrorCommand.execute(error: "設定ファイルが不正です。設定ファイルの読み込みに失敗しました")
    ProconBypassMan::DeviceStatus.change_to_setting_syntax_error_and_shutdown!
    FileUtils.rm_rf(ProconBypassMan.pid_path)
    FileUtils.rm_rf(ProconBypassMan.digest_path)
    exit 1
  rescue ProconBypassMan::NotFoundProconError
    ProconBypassMan::SendErrorCommand.execute(error: "プロコンが見つかりませんでした。終了します。")
    ProconBypassMan::DeviceStatus.change_to_procon_not_found_error!
    FileUtils.rm_rf(ProconBypassMan.pid_path)
    FileUtils.rm_rf(ProconBypassMan.digest_path)
    exit 1
  rescue ProconBypassMan::ConnectionError
    begin
      raise
    rescue ProconBypassMan::EternalConnectionError
      ProconBypassMan::SendErrorCommand.execute(error: "接続の見込みがないのでsleepしまくります")
      ProconBypassMan::DeviceStatus.change_to_connected_but_sleeping!
      FileUtils.rm_rf(ProconBypassMan.pid_path)
      eternal_sleep
    rescue ProconBypassMan::FirstConnectionError
      ProconBypassMan::SendErrorCommand.execute(error: "接続を確立できませんでした。やりなおします。")
      retry
    end
  rescue ProconBypassMan::GracefulShutdown
    FileUtils.rm_rf(ProconBypassMan.pid_path)
    FileUtils.rm_rf(ProconBypassMan.digest_path)
    exit 1
  end

  def self.configure(&block)
    @@configuration = ProconBypassMan::Configuration.new
    @@configuration.instance_eval(&block)
    @@configuration
  end

  # @return [ProconBypassMan::Configuration]
  def self.config
    @@configuration ||= ProconBypassMan::Configuration.new
  end

  # @return [void]
  def self.reset!
    ProconBypassMan::Procon::MacroRegistry.reset!
    ProconBypassMan::Procon::ModeRegistry.reset!
    ProconBypassMan::Procon.reset!
    ProconBypassMan::ButtonsSettingConfiguration.instance.reset!
    ProconBypassMan::IOMonitor.reset!
  end

  def self.initialize_pbm
    ProconBypassMan::WriteDeviceIdCommand.execute
    ProconBypassMan::WriteSessionIdCommand.execute
    File.write(pid_path, $$)
    ProconBypassMan::DeviceStatus.change_to_running!
  end

  def self.eternal_sleep
    sleep(999999999)
  end

  # @return [Void]
  def self.hot_reload!
    Process.kill(:USR2, pid)
  end
end
