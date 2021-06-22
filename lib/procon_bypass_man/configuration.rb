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
    module Validator
      # @return [Boolean]
      def valid?
        @errors = Hash.new {|h,k| h[k] = [] }
        if prefix_keys.empty?
          @errors[:prefix_keys] ||= []
          @errors[:prefix_keys] << "prefix_keys_for_changing_layerに値が入っていません。"
        end

        @errors.empty?
      end

      # @return [Boolean]
      def invalid?
        !valid?
      end

      # @return [Hash]
      def errors
        @errors ||= Hash.new {|h,k| h[k] = [] }
      end
    end

    module Loader
      def self.load(setting_path: )
        validation_instance = ProconBypassMan::Configuration.switch_context(:validation) do |instance|
          begin
            yaml = YAML.load_file(setting_path) or raise "読み込みに失敗しました"
            instance.instance_eval(yaml["setting"])
          rescue SyntaxError
            instance.errors[:base] << "Rubyのシンタックスエラーです"
            next(instance)
          rescue Psych::SyntaxError
            instance.errors[:base] << "yamlのシンタックスエラーです"
            next(instance)
          end
          instance.valid?
          next(instance)
        end

        if !validation_instance.errors.empty?
          raise ProconBypassMan::CouldNotLoadConfigError, validation_instance.errors
        end

        yaml = YAML.load_file(setting_path)
        ProconBypassMan::Configuration.instance.setting_path = setting_path
        ProconBypassMan::Configuration.instance.reset!
        ProconBypassMan.reset!

        case yaml["version"]
        when 1.0, nil
          ProconBypassMan::Configuration.instance.instance_eval(yaml["setting"])
        else
          ProconBypassMan.logger.warn "不明なバージョンです。failoverします"
          ProconBypassMan::Configuration.instance.instance_eval(yaml["setting"])
        end
        ProconBypassMan::Configuration.instance
      end

      def self.reload_setting
        self.load(setting_path: ProconBypassMan::Configuration.instance.setting_path)
      end
    end

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

    def self.dump
      { context: @@context, current_context_key: @@current_context_key }
    end

    def initialize
      reset!
    end

    MODES = [:manual]
    def layer(direction, mode: :manual, &block)
      unless (MODES + ProconBypassMan::Procon::ModeRegistry.plugins.keys).include?(mode)
        raise("#{mode} mode is unknown")
      end

      layer = Layer.new(mode: mode)
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
