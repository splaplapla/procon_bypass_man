module ProconBypassMan
  class Configuration
    module Validator
      # @return [Boolean]
      def valid?
        @errors = Hash.new {|h,k| h[k] = [] }

        validate_require_prefix_keys
        validate_config_of_button_lonely
        validate_verify_button_existence
        validate_flip_and_remap_are_hate_each_other

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

      private

      def validate_config_of_button_lonely
        @layers.each do |layer_key, value|
          if ProconBypassMan::Procon::ModeRegistry::PRESETS.key?(value.mode)
            next
          else
            if !value.flips.empty? || !value.macros.empty?
              @errors[:layers] << "#{layer_key}でmodeを設定しているのでボタンの設定はできません。"
            end
          end
        end
      end

      def validate_require_prefix_keys
        if prefix_keys.empty?
          @errors[:prefix_keys] ||= []
          @errors[:prefix_keys] << "prefix_keys_for_changing_layerに値が入っていません。"
        end
      end

      def validate_verify_button_existence
        @layers.each do |layer_key, value|
          unverified_buttons = []
          # teplevel target button
          value.instance_eval { @flips.keys }.map(&:to_sym).each { |b| unverified_buttons << b }
          value.instance_eval { @remaps.keys }.map(&:to_sym).each { |b| unverified_buttons << b }
          # internal target button
          value.instance_eval {
            @flips.flat_map { |flip_button, flip_option|
              flip_option.flat_map { |flip_option_key, flip_option_target_button|
                next if flip_option_key == :flip_interval
                next if flip_option_target_button.is_a?(FalseClass) || flip_option_target_button.is_a?(TrueClass)
                flip_option_target_button
              }
            }
          }.compact.each { |b| unverified_buttons << b }
          value.instance_eval {
            @remaps.flat_map { |button, option|
              option.flat_map { |flip_option_key, flip_option_target_button|
                next if flip_option_target_button.is_a?(FalseClass) || flip_option_target_button.is_a?(TrueClass)
                flip_option_target_button
              }
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
          value.instance_eval { @flips.keys }.map(&:to_sym).each { |b| flip_buttons << b }
          value.instance_eval { @remaps.keys }.map(&:to_sym).each { |b| remap_buttons << b }
          if(duplicated_buttons = flip_buttons & remap_buttons).length > 0
            @errors[:layers] << "レイヤー#{layer_key}で、連打とリマップの定義が重複しているボタン#{duplicated_buttons.join(", ")}があります"
          end
        end
      end
    end
  end
end
