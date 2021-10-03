require "logger"
require 'yaml'
require "fileutils"

require_relative "procon_bypass_man/version"
require_relative "procon_bypass_man/timer"
require_relative "procon_bypass_man/bypass"
require_relative "procon_bypass_man/bypass_mutex"
require_relative "procon_bypass_man/device_connector"
require_relative "procon_bypass_man/runner"
require_relative "procon_bypass_man/processor"
require_relative "procon_bypass_man/configuration"
require_relative "procon_bypass_man/procon"
require_relative "procon_bypass_man/procon/debug_dumper"
require_relative "procon_bypass_man/procon/analog_stick_cap"
require_relative "procon_bypass_man/reporter"
require_relative "procon_bypass_man/error_reporter"
require_relative "procon_bypass_man/on_memory_cache"

STDOUT.sync = true
Thread.abort_on_exception = true

# new feature from ruby3.0
if GC.respond_to?(:auto_compact)
  GC.auto_compact = true
end

module ProconBypassMan
  class ProConRejected < StandardError; end
  class CouldNotLoadConfigError < StandardError; end
  class FirstConnectionError < StandardError; end
  class EternalConnectionError < StandardError; end

  def self.configure(setting_path: nil, &block)
    unless setting_path
      logger.warn "setting_pathが未設定です。設定ファイルのライブリロードが使えません。"
    end

    if block_given?
      ProconBypassMan::Configuration.instance.instance_eval(&block)
    else
      ProconBypassMan::Configuration::Loader.load(setting_path: setting_path)
    end
  end

  def self.run(setting_path: nil, &block)
    configure(setting_path: setting_path, &block)
    File.write(pid_path, $$)
    Runner.new.run
  rescue CouldNotLoadConfigError
    ProconBypassMan.logger.error "設定ファイルが不正です。設定ファイルの読み込みに失敗しました"
    puts "設定ファイルが不正です。設定ファイルの読み込みに失敗しました"
    FileUtils.rm_rf(ProconBypassMan.pid_path)
    FileUtils.rm_rf(ProconBypassMan.digest_path)
    exit 1
  rescue EternalConnectionError
    ProconBypassMan.logger.error "接続の見込みがないのでsleepしまくります"
    puts "接続の見込みがないのでsleepしまくります"
    FileUtils.rm_rf(ProconBypassMan.pid_path)
    sleep(999999999)
  rescue FirstConnectionError
    puts "接続を確立できませんでした。やりなおします。"
    retry
  end

  def self.logger=(logger)
    @@logger = logger
  end

  # @return [Logger]
  def self.logger
    if defined?(@@logger) && @@logger.is_a?(Logger)
      @@logger
    else
      Logger.new(nil)
    end
  end

  def self.enable_critical_error_logging!
    @@enable_critical_error_logging = true
  end

  def self.error_logger
    if defined?(@@enable_critical_error_logging)
      @@error_logger ||= Logger.new("#{ProconBypassMan.root}/error.log", 5, 1024 * 1024 * 10)
    else
      Logger.new(nil)
    end
  end

  def self.pid_path
    @@pid_path ||= File.expand_path("#{root}/pbm_pid", __dir__).freeze
  end

  def self.reset!
    ProconBypassMan::Procon::MacroRegistry.reset!
    ProconBypassMan::Procon::ModeRegistry.reset!
    ProconBypassMan::Procon.reset!
    ProconBypassMan::Configuration.instance.reset!
    ProconBypassMan::IOMonitor.reset!
  end

  def self.root
    if defined?(@@root)
      @@root
    else
      File.expand_path('..', __dir__).freeze
    end
  end

  def self.root=(path)
    @@root = path
  end

  def self.api_server=(api_server)
    @@api_server = api_server
  end

  def self.api_server
    if defined?(@@api_server)
      @@api_server
    else
      nil
    end
  end

  def self.cache
    @@cache_table ||= ProconBypassMan::OnMemoryCache.new
  end

  def self.digest_path
    "#{root}/.setting_yaml_digest"
  end
end
