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
          unverified_buttons = value.instance_eval { @flips.keys }.map(&:to_sym)
          unless (unverified_buttons - ProconBypassMan::Procon::ButtonCollection::BUTTONS).length.zero?
            @errors[:layers] << "#{layer_key}で存在しないボタン#{unverified_buttons.join(", ")}があります"
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
