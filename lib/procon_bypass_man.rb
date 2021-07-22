require "logger"
require 'yaml'
require "fileutils"

require_relative "procon_bypass_man/version"
require_relative "procon_bypass_man/bypass"
require_relative "procon_bypass_man/bypass_supporter"
require_relative "procon_bypass_man/runner"
require_relative "procon_bypass_man/processor"
require_relative "procon_bypass_man/configuration"
require_relative "procon_bypass_man/procon"

STDOUT.sync = true
Thread.abort_on_exception = true

module ProconBypassMan
  class ProConRejected < StandardError; end
  class CouldNotLoadConfigError < StandardError; end
  class FirstConnectionError < StandardError; end

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
    exit 1
  rescue FirstConnectionError
    puts "接続を確立できませんでした。やりなおします。"
    retry
  end

  def self.logger=(logger)
    @@logger = logger
  end

  def self.logger
    if defined?(@@logger)
      @@logger
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
end
