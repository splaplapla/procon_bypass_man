module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class IfPressed
        attr_reader :value

        def initialize(value)
          @value = value
        end

        def to_value!
          case value
          when Integer, TrueClass, FalseClass, NilClass
            raise UnSupportValueError
          when Symbol, String
            return [value.to_sym]
          when Array
            return value.map(&:to_sym).uniq
          else
            raise UnexpectedValueError
          end
        end
      end
    end
  end
end
