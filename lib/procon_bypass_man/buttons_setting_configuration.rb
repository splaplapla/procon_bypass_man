require "procon_bypass_man/buttons_setting_configuration/validator"
require "procon_bypass_man/buttons_setting_configuration/loader"
require "procon_bypass_man/buttons_setting_configuration/layer"

module ProconBypassMan
  class AnalogStickPosition < Struct.new(:x, :y); end

  class ButtonsSettingConfiguration
    attr_accessor :layers,
      :setting_path,
      :mode_plugins,
      :macro_plugins,
      :context,
      :current_context_key,
      :neutral_position

    def self.instance
      @@current_context_key ||= :main
      @@context ||= {}
      @@context[@@current_context_key] ||= new
    end

    def self.instance=(val)
      @@context[@@current_context_key] = val
    end

    def self.switch_new_context(key)
      @@context[key] = new
      previous_key = @@current_context_key
      if block_given?
        @@current_context_key = key
        value = yield(@@context[key])
        @@current_context_key = previous_key
        return value
      else
        @@current_context_key = key
      end
    end

    def initialize
      reset!
      self.class.instance = self
    end

    module ManualMode
      def self.name
        'manual'
      end
    end
    def layer(direction, mode: ManualMode, &block)
      mode_name = case mode
                  when String
                    mode.to_sym
                  when Symbol
                    mode
                  else
                    mode.name.to_sym
                  end
      unless ([ManualMode.name.to_sym] + ProconBypassMan::Procon::ModeRegistry.plugins.keys).include?(mode_name)
        raise("#{mode_name} mode is unknown")
      end

      layer = Layer.new(mode: mode_name)
      layer.instance_eval(&block) if block_given?
      self.layers[direction] = layer
      self
    end

    def install_mode_plugin(klass)
      ProconBypassMan::Procon::ModeRegistry.install_plugin(klass)
      self
    end

    def install_macro_plugin(klass)
      ProconBypassMan::Procon::MacroRegistry.install_plugin(klass)
      self
    end

    def prefix_keys_for_changing_layer(buttons)
      @prefix_keys_for_changing_layer = buttons
      self
    end

    def set_neutral_position(x, y)
      self.neutral_position = AnalogStickPosition.new(x, y).freeze
      self
    end

    def prefix_keys
      @prefix_keys_for_changing_layer
    end

    def reset!
      @prefix_keys_for_changing_layer = []
      self.mode_plugins = {}
      self.macro_plugins = {}
      self.layers = {
        up: Layer.new,
        down: Layer.new,
        left: Layer.new,
        right: Layer.new,
      }
      @neutral_position = AnalogStickPosition.new(2124, 1808).freeze
    end
  end
end
