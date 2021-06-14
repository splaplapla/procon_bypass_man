module ProconBypassMan
  class Configuration
    attr_accessor :layers

    def self.instance
      @@instance ||= new
    end

    def initialize
      @prefix_keys_for_changing_layer = [:zr, :r, :zl, :l]
      self.layers = {
        up: Layer.new { flip [:down, :zr] },
        down: Layer.new { flip [:down, :zr] },
        left: Layer.new,
        right: Layer.new,
      }
    end

    MODES = [:normal, :random]
    def layer(direction, mode: :normal, &block)
      raise("unknown mode") unless MODES.include?(mode)

      layer = Layer.new(mode: mode)
      layer.instance_eval(&block)
      self.layers[direction] = layer
    end

    def prefix_keys_for_changing_layer(buttons)
      @prefix_keys_for_changing_layer = buttons
    end

    def prefix_keys
      @prefix_keys_for_changing_layer
    end
  end
end
