require "logger"
require 'yaml'
require "json"
require "net/http"
require "fileutils"
require "securerandom"

require_relative "procon_bypass_man/version"
require_relative "procon_bypass_man/support/signal_handler"
require_relative "procon_bypass_man/support/callbacks"
require_relative "procon_bypass_man/support/safe_timeout"
require_relative "procon_bypass_man/support/compress_array"
require_relative "procon_bypass_man/support/uptime"
require_relative "procon_bypass_man/support/on_memory_cache"
require_relative "procon_bypass_man/support/http_client"
require_relative "procon_bypass_man/background"
require_relative "procon_bypass_man/commands"
require_relative "procon_bypass_man/bypass"
require_relative "procon_bypass_man/device_connector"
require_relative "procon_bypass_man/runner"
require_relative "procon_bypass_man/processor"
require_relative "procon_bypass_man/configuration"
require_relative "procon_bypass_man/buttons_setting_configuration"
require_relative "procon_bypass_man/procon"
require_relative "procon_bypass_man/procon_reader"
require_relative "procon_bypass_man/procon/analog_stick"
require_relative "procon_bypass_man/procon/analog_stick_cap"
require_relative "procon_bypass_man/splatoon2"

STDOUT.sync = true
Thread.abort_on_exception = true

module ProconBypassMan
  extend ProconBypassMan::Configuration::ClassMethods

  class CouldNotLoadConfigError < StandardError; end
  class FirstConnectionError < StandardError; end
  class EternalConnectionError < StandardError; end

  def self.buttons_setting_configure(setting_path: nil, &block)
    unless setting_path
      logger.warn "setting_pathが未設定です。設定ファイルのライブリロードが使えません。"
    end

    if block_given?
      ProconBypassMan::ButtonsSettingConfiguration.instance.instance_eval(&block)
    else
      ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting_path)
    end
  end

  # @return [void]
  def self.run(setting_path: nil, &block)
    ProconBypassMan.logger.info "PBMを起動しています"
    puts "PBMを起動しています"
    buttons_setting_configure(setting_path: setting_path, &block)
    initialize_pbm
    File.write(pid_path, $$)
    ProconBypassMan::WriteSessionIdCommand.execute
    ProconBypassMan::Background::JobRunner.start!
    gadget, procon = ProconBypassMan::ConnectDeviceCommand.execute!
    Runner.new(gadget: gadget, procon: procon).run
  rescue CouldNotLoadConfigError
    ProconBypassMan::SendErrorCommand.execute(error: "設定ファイルが不正です。設定ファイルの読み込みに失敗しました")
    FileUtils.rm_rf(ProconBypassMan.pid_path)
    FileUtils.rm_rf(ProconBypassMan.digest_path)
    exit 1
  rescue EternalConnectionError
    ProconBypassMan::SendErrorCommand.execute(error: "接続の見込みがないのでsleepしまくります")
    FileUtils.rm_rf(ProconBypassMan.pid_path)
    sleep(999999999)
  rescue FirstConnectionError
    ProconBypassMan::SendErrorCommand.execute(error: "接続を確立できませんでした。やりなおします。")
    retry
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
  end
end
