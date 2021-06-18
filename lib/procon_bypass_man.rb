require "logger"

require_relative "procon_bypass_man/version"
require_relative "procon_bypass_man/device_registry"
require_relative "procon_bypass_man/bypass"
require_relative "procon_bypass_man/runner"
require_relative "procon_bypass_man/processor"
require_relative "procon_bypass_man/procon/data"
require_relative "procon_bypass_man/procon"
require_relative "procon_bypass_man/configuration"
require_relative "procon_bypass_man/plugin_integration"

STDOUT.sync = true
Thread.abort_on_exception = true

module ProconBypassMan
  class ProConRejected < StandardError; end

  def self.configure(&block)
    ProconBypassMan::Configuration.instance.instance_eval(&block)
  end

  def self.run(&block)
    configure(&block) if block_given?
    registry = ProconBypassMan::DeviceRegistry.new
    Runner.new(gadget: registry.gadget, procon: registry.procon).run
  end

  def self.logger=(dev)
    @@logger = Logger.new(dev, 5, 1024 * 10) # 5世代まで残して, 10MBでローテーション
  end

  def self.logger
    if @@logger
      @@logger
    else
      Logger.new(nil)
    end
  end

  def self.reset!
    ProconBypassMan::Procon::MacroRegistry.reset!
    ProconBypassMan::Procon::ModeRegistry.reset!
    ProconBypassMan::Procon.reset!
  end
end
