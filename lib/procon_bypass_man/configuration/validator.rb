module ProconBypassMan
  class Configuration
    module Validator
      # @return [Boolean]
      def valid?
        @errors = Hash.new {|h,k| h[k] = [] }
        if prefix_keys.empty?
          @errors[:prefix_keys] ||= []
          @errors[:prefix_keys] << "prefix_keys_for_changing_layerに値が入っていません。"
        end

        @layers.each do |layer_key, value|
          if ProconBypassMan::Procon::ModeRegistry::PRESETS.key?(value.mode)
            next
          else
            if !value.flips.empty? || !value.macros.empty?
              @errors[:layers] << "#{layer_key}でmodeを設定しているのでボタンの設定はできません。"
            end
          end
        end

        @layers.each do |layer_key, value|
          # teplevel target button
          unverified_buttons = value.instance_eval { @flips.keys }.map(&:to_sym)
          # internal target button
          value.instance_eval {
            @flips.flat_map { |flip_button, flip_option|
              flip_option.flat_map { |flip_option_key, flip_option_target_button|
                next if flip_option_target_button.is_a?(FalseClass) || flip_option_target_button.is_a?(TrueClass)
                flip_option_target_button
              }
            }
          }.compact.each { |b| unverified_buttons << b }
          unless(nunsupport_buttons = (unverified_buttons - ProconBypassMan::Procon::ButtonCollection::BUTTONS)).length.zero?
            @errors[:layers] << "#{layer_key}で存在しないボタン#{nunsupport_buttons.join(", ")}があります"
          end
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
  end
end
