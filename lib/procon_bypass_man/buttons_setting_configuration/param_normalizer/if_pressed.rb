module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      # falsyを許可する
      class IfPressed
        attr_reader :value

        def initialize(value)
          @value = value
        end

        def to_value!
          case value
          when Integer, TrueClass
            raise UnSupportValueError
          when Symbol, String
            return [value.to_sym]
          when Array
            return value.map(&:to_sym).uniq
          when FalseClass, NilClass
            # OK
          else
            raise UnexpectedValueError
          end
        end
      end
    end
  end
end
