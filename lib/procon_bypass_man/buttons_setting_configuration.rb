require "procon_bypass_man/buttons_setting_configuration/validator"
require "procon_bypass_man/buttons_setting_configuration/loader"
require "procon_bypass_man/buttons_setting_configuration/layer"

module ProconBypassMan
  class Position < Struct.new(:x, :y); end

  class ButtonsSettingConfiguration
    attr_accessor :layers,
      :setting_path,
      :mode_plugins,
      :macro_plugins,
      :neutral_position

    def self.instance
      @@context ||= {}
      @@context[current_context_key] ||= new
    end

    def self.current_context_key
      @@current_context_key ||= :main
    end

    def self.instance=(val)
      @@context[current_context_key] = val
    end

    def self.switch_new_context(new_context_key)
      @@context[new_context_key] = new
      previous_key = current_context_key
      if block_given?
        @@current_context_key = new_context_key
        value = yield(@@context[new_context_key])
        return value
      else
        @@current_context_key = new_context_key
      end
    ensure
      @@current_context_key = previous_key
    end

    def initialize
      reset!
    end

    module ManualMode
      def self.name
        :manual
      end
    end
    def layer(direction, mode: ManualMode, &block)
      if ProconBypassMan::ButtonsSettingConfiguration::ManualMode == mode
        mode_name = mode.name
      else
        mode_name = case mode
                    when ProconBypassMan::ButtonsSettingConfiguration::ManualMode
                      mode.name
                    when String
                      mode.to_sym
                    when Symbol
                      mode
                    else
                      mode.to_s.to_sym
                    end
      end

      unless ([ManualMode.name] + ProconBypassMan::Procon::ModeRegistry.plugins.keys).include?(mode_name)
        warn "#{mode_name}モードがinstallされていません"
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
      self.neutral_position = Position.new(x, y).freeze
      self
    end

    def prefix_keys
      @prefix_keys_for_changing_layer
    end

    def reset!
      @prefix_keys_for_changing_layer = []
      self.mode_plugins = {}
      # プロセスを一度起動するとsetting_pathは変わらない、という想定なので適当に扱う. resetでは初期化しない
      # self.setting_path = nil
      self.macro_plugins = {}
      self.layers = {
        up: Layer.new,
        down: Layer.new,
        left: Layer.new,
        right: Layer.new,
      }
      @neutral_position = Position.new(2124, 1808).freeze
    end
  end
end
