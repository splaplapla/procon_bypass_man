require_relative "procon_bypass_man/version"
require_relative "procon_bypass_man/has_devices"
require_relative "procon_bypass_man/runner"

STDOUT.sync = true
Thread.abort_on_exception = true

module ProconBypassMan
  class Error < StandardError; end

  include HasDevices

  def self.run
    instance = new
    instance.init_devices
    yield(ProconBypassMan::PluginIntegration.instance)
    Runner.new(gadget: instance.gadget, procon: procon).run
  end

  def self.logger(text)
    # TODO replace Logger
    puts text
  end
end
