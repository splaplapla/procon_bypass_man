module ProconBypassMan
  class Layer
    attr_accessor :mode, :flips

    def initialize(mode: :manual, &block)
      self.mode = mode
      self.flips = {}
      instance_eval(&block) if block_given?
    end

    # @param [Symbol] button
    def flip(button, if_pushed: false, channel: nil, force_neutral: nil)
      case if_pushed
      when TrueClass
        if_pushed = [button]
      when Symbol
        if_pushed = [if_pushed]
      when Array, FalseClass
        # sono mama
      else
        raise "not support class"
      end
      hash = { if_pushed: if_pushed }
      if channel
        hash[:channel] = channel
      end
      if force_neutral
        hash[:force_neutral] = force_neutral
      end
      self.flips[button] = hash
    end

    # @return [Array]
    def flip_buttons
      flips || {}
    end
  end

  class Configuration
    attr_accessor :layers

    def self.instance
      @@instance ||= new
    end

    def initialize
      @prefix_keys_for_changing_layer = []
      self.layers = {
        up: Layer.new,
        down: Layer.new,
        left: Layer.new,
        right: Layer.new,
      }
    end

    MODES = [:manual, :auto]
    def layer(direction, mode: :manual, &block)
      raise("unknown mode") unless MODES.include?(mode)

      layer = Layer.new(mode: mode)
      layer.instance_eval(&block) if block_given?
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
