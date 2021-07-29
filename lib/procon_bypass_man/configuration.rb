require "procon_bypass_man/configuration/validator"
require "procon_bypass_man/configuration/loader"
require "procon_bypass_man/configuration/layer"

module ProconBypassMan
  class Configuration
    include Validator

    attr_accessor :layers,
      :setting_path,
      :mode_plugins,
      :macro_plugins,
      :context,
      :current_context_key

    def self.instance
      @@current_context_key ||= :main
      @@context ||= {}
      @@context[@@current_context_key] ||= new
    end

    def self.switch_context(key)
      @@context[key] ||= new
      previous_key = @@current_context_key
      if block_given?
        @@current_context_key = key
        value = yield(@@context[key])
        @@context[key].reset!
        @@current_context_key = previous_key
        return value
      else
        @@current_context_key = key
      end
    end

    def initialize
      reset!
    end

    MODES = [:manual]
    def layer(direction, mode: :manual, &block)
      if mode.respond_to?(:name)
        mode_name = mode.name.to_sym
      else
        mode_name = mode
      end
      unless (MODES + ProconBypassMan::Procon::ModeRegistry.plugins.keys).include?(mode_name)
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
    end
  end
end
