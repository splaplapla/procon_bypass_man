module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class ButtonList
        attr_reader :button

        def initialize(button)
          @button = button
        end

        # @return [Array]
        # @raise [UnSupportValueError]
        # @raise [UnexpectedValueError]
        def to_value!
          case button
          when Integer, TrueClass, FalseClass, NilClass
            raise UnSupportValueError
          when Symbol
            return [button]
          when String
            return [button.to_sym]
          when Array
            return button.map(&:to_sym).uniq
          else
            raise UnexpectedValueError
          end
        end
      end
    end
  end
end
