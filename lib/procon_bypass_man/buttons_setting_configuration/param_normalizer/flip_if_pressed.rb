module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class FlipIfPressed
        attr_reader :value

        def initialize(value, button: )
          @value = value
          @button = button
        end

        def to_value!
          case value
          when Integer
            raise UnSupportValueError
          when TrueClass
            return [@button]
          when Symbol, String
            return [value.to_sym]
          when Array
            return value.map(&:to_sym).uniq
          when FalseClass, NilClass
            return false
          else
            raise UnexpectedValueError
          end
        end
      end
    end
  end
end
