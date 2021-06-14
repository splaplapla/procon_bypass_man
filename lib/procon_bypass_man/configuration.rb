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

    def layer(direction, &block)
      self.layers[direction] = Layer.new.instance_eval(&block)
    end

    def prefix_keys_for_changing_layer(buttons=nil)
      return @prefix_keys_for_changing_layer if buttons.nil?
      @prefix_keys_for_changing_layer = buttons
    end

    def prefix_keys
      @prefix_keys_for_changing_layer
    end
  end
end
