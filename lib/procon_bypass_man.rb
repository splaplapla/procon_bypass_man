require_relative "procon_bypass_man/version"
require_relative "procon_bypass_man/device_registry"
require_relative "procon_bypass_man/runner"
require_relative "procon_bypass_man/processor"
require_relative "procon_bypass_man/procon"
require_relative "procon_bypass_man/layer"
require_relative "procon_bypass_man/plugin_integration"

STDOUT.sync = true
Thread.abort_on_exception = true

module ProconBypassMan
  class ProConRejected < StandardError; end

  class Configuration
    attr_accessor :prefix_keys_for_changing_layer
    attr_accessor :layers

    def self.instance
      @@instance ||= new
    end

    def initialize
      self.prefix_keys_for_changing_layer = [:zr, :r, :zl, :l]
      self.layers = {
        up: Layer.new { flip [:down, :zr] },
        down: Layer.new { flip [:down, :zr] },
        left: Layer.new,
        right: Layer.new,
      }
    end

    def layer(direction)
      self.layers[direction] = yield(Layer.new)
    end
  end

  def self.run
    registry = ProconBypassMan::DeviceRegistry.new
    yield(Configuration.instance) if block_given?
    Runner.new(gadget: registry.gadget, procon: registry.procon).run
  end

  def self.logger(prefix=nil, text)
    # TODO replace Logger
    # pp "pure: #{text}"
    # pp "unpack(bin): #{text.unpack("b*")}"
    pp "unpack(Hex): #{text.unpack("H*")}"
  end
end
