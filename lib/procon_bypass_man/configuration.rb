module ProconBypassMan
  class Layer
    attr_accessor :mode, :flips, :macros

    def initialize(mode: :manual, &block)
      self.mode = mode
      self.flips = {}
      self.macros = {}
      instance_eval(&block) if block_given?
    end

    # @param [Symbol] button
    def flip(button, if_pressed: false, channel: nil, force_neutral: nil)
      case if_pressed
      when TrueClass
        if_pressed = [button]
      when Symbol
        if_pressed = [if_pressed]
      when Array, FalseClass
        # sono mama
      else
        raise "not support class"
      end
      hash = { if_pressed: if_pressed }
      if channel
        hash[:channel] = channel
      end
      if force_neutral
        hash[:force_neutral] = force_neutral
      end
      self.flips[button] = hash
    end

    PRESET_MACROS = [:fast_return]
    def macro(name, if_pressed: )
      self.macros[name] = { if_pressed: if_pressed }
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

    MODES = [:manual, :auto, :guruguru]
    def layer(direction, mode: :manual, &block)
      unless (MODES + ProconBypassMan::Procon::ModeRegistry.plugins.keys).include?(mode)
        raise("#{mode} mode is unknown")
      end

      layer = Layer.new(mode: mode)
      layer.instance_eval(&block) if block_given?
      self.layers[direction] = layer
    end

    def install_mode_plugin(klass)
      ProconBypassMan::Procon::ModeRegistry.install_plugin(klass)
    end

    def install_macro_plugin(klass)
      ProconBypassMan::Procon::MacroRegistry.install_plugin(klass)
    end

    def prefix_keys_for_changing_layer(buttons)
      @prefix_keys_for_changing_layer = buttons
    end

    def prefix_keys
      @prefix_keys_for_changing_layer
    end
  end
end
