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
