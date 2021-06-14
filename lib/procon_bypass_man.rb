require_relative "procon_bypass_man/version"
require_relative "procon_bypass_man/device_registry"
require_relative "procon_bypass_man/runner"
require_relative "procon_bypass_man/processor"
require_relative "procon_bypass_man/procon"
require_relative "procon_bypass_man/layer"
require_relative "procon_bypass_man/configuration"
require_relative "procon_bypass_man/plugin_integration"

STDOUT.sync = true
Thread.abort_on_exception = true

module ProconBypassMan
  class ProConRejected < StandardError; end

  def self.configure(&block)
    ProconBypassMan::Configuration.instance.instance_eval(&block) if block_given?
  end

  def self.run(&block)
    registry = ProconBypassMan::DeviceRegistry.new
    ProconBypassMan::Configuration.instance.instance_eval(&block) if block_given?
    Runner.new(gadget: registry.gadget, procon: registry.procon).run
  end

  def self.logger(prefix=nil, text)
    # TODO replace Logger
    # pp "pure: #{text}"
    # pp "unpack(bin): #{text.unpack("b*")}"
    pp "unpack(Hex): #{text.unpack("H*")}"
  end
end
