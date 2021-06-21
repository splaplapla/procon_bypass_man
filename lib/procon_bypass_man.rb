require "logger"
require 'yaml'

require_relative "procon_bypass_man/version"
require_relative "procon_bypass_man/device_registry"
require_relative "procon_bypass_man/bypass"
require_relative "procon_bypass_man/runner"
require_relative "procon_bypass_man/processor"
require_relative "procon_bypass_man/procon/data"
require_relative "procon_bypass_man/procon"
require_relative "procon_bypass_man/configuration"

STDOUT.sync = true
Thread.abort_on_exception = true

module ProconBypassMan
  class ProConRejected < StandardError; end

  def self.configure(setting_path: nil, &block)
    unless setting_path
      logger.warn "setting_pathが未設定です。設定ファイルのライブリロードが使えません。"
    end

    if block_given?
      ProconBypassMan::Configuration.instance.instance_eval(&block)
    else
      yaml = YAML.load_file(setting_path) or raise "読み込みに失敗しました"
      case yaml["version"]
      when 1.0, nil
        ProconBypassMan::Configuration.instance.instance_eval(yaml["setting"])
      else
        logger.warn "不明なバージョンでfailoverします"
        ProconBypassMan::Configuration.instance.instance_eval(yaml["setting"])
      end
    end
  end

  def self.run(setting_path: nil, &block)
    configure(&block) if block_given?
    registry = ProconBypassMan::DeviceRegistry.new
    Runner.new(gadget: registry.gadget, procon: registry.procon).run
  end

  def self.logger=(dev)
    @@logger = Logger.new(dev, 5, 1024 * 1024 * 10) # 5世代まで残して, 10MBでローテーション
  end

  def self.logger
    if defined?(@@logger)
      @@logger
    else
      Logger.new(nil)
    end
  end

  def self.reset!
    ProconBypassMan::Procon::MacroRegistry.reset!
    ProconBypassMan::Procon::ModeRegistry.reset!
    ProconBypassMan::Procon.reset!
    ProconBypassMan::IOMonitor.reset!
  end
end
