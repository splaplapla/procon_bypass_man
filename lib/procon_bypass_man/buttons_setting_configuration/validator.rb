module ProconBypassMan
  class ButtonsSettingConfiguration
    class Validator
      def initialize(config)
        @macro_plugins = config.macro_registry.plugins
        @mode_plugins = config.mode_plugins
        @layers = config.layers
        @prefix_keys = config.prefix_keys
      end

      # @return [Boolean]
      def valid?
        @errors = Hash.new {|h,k| h[k] = [] }

        warn_blank_prefix_keys
        validate_config_of_button_lonely
        validate_verify_button_existence
        validate_flip_and_remap_are_hate_each_other
        validate_verify_mode_plugins
        validate_verify_macro_plugins

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

      # @return [Array<String>]
      def errors_to_s
        errors.map { |_x, message|
          value = <<~EOH
            #{message.map { |m| "layer #{m}" }.join("\n")}
          EOH
          value.chomp
        }.join("\n")
      end

      private

      def validate_config_of_button_lonely
        @layers.each do |layer_key, value|
          if ProconBypassMan.buttons_setting_configuration.mode_registry.presets.key?(value.mode)
            next
          else
            if !value.flips.empty? || !value.macros.empty?
              @errors[:layers] << "#{layer_key}でmodeを設定しているのでボタンの設定はできません。"
            end
          end
        end
      end

      # @return [void]
      def warn_blank_prefix_keys
        if @prefix_keys.empty?
          ProconBypassMan.logger.warn "prefix_keys_for_changing_layerに値が入っていません。"
        end
      end

      def validate_verify_button_existence
        @layers.each do |layer_key, value|
          unverified_buttons = []
          # teplevel target button
          value.flips.keys.map(&:to_sym).each { |b| unverified_buttons << b }
          value.remaps.keys.map(&:to_sym).each { |b| unverified_buttons << b }
          # internal target button
          value.flips.flat_map { |_flip_button, flip_option|
            flip_option.flat_map { |flip_option_key, flip_option_target_button|
              next if flip_option_key == :flip_interval
              next if flip_option_target_button.is_a?(FalseClass) || flip_option_target_button.is_a?(TrueClass)
              flip_option_target_button
            }
          }.compact.each { |b| unverified_buttons << b }
          value.remaps.flat_map { |_button, option|
            option.flat_map { |_flip_option_key, flip_option_target_button|
              next if flip_option_target_button.is_a?(FalseClass) || flip_option_target_button.is_a?(TrueClass)
              flip_option_target_button
            }
          }.compact.each { |b| unverified_buttons << b }
          unless(nunsupport_buttons = (unverified_buttons - ProconBypassMan::Procon::ButtonCollection::BUTTONS)).length.zero?
            @errors[:layers] << "#{layer_key}で存在しないボタン#{nunsupport_buttons.join(", ")}があります"
          end
        end
      end

      def validate_flip_and_remap_are_hate_each_other
        @layers.each do |layer_key, value|
          flip_buttons = []
          remap_buttons = []
          value.flips.keys.map(&:to_sym).each { |b| flip_buttons << b }
          value.remaps.keys.map(&:to_sym).each { |b| remap_buttons << b }
          if(duplicated_buttons = flip_buttons & remap_buttons).length > 0
            @errors[:layers] << "レイヤー#{layer_key}で、連打とリマップの定義が重複しているボタン#{duplicated_buttons.join(", ")}があります"
          end
        end
      end

      def validate_verify_mode_plugins
        @mode_plugins.each do |key, mode|
          begin
            Module.const_get(key.to_s)
          rescue NameError
            next
          end

          if(const = Module.const_get(key.to_s))
            if not (const.respond_to?(:binaries) && mode.call)
              @errors[:mode] << "モード #{key}を読み込めませんでした。"
            end
          end
        end
      end

      def validate_verify_macro_plugins
        @macro_plugins.each do |key, macro|
          begin
            Module.const_get(key.to_s)
          rescue NameError
            next
          end

          if(const = Module.const_get(key.to_s))
            if not (const.respond_to?(:steps) && macro.call)
              @errors[:macro] << "マクロ #{key}を読み込めませんでした。"
            end
          end
        end
      end
    end
  end
end
