module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class DisableMacroIfPressed
        attr_reader :value

        def initialize(value)
          @value = value
        end

        def to_value!
          case value
          when FalseClass, Integer, TrueClass
            raise UnSupportValueError
          when Symbol, String
            return [value.to_sym]
          when Array
            return value.map(&:to_sym).uniq
          when NilClass # 常に対象のmacroをdisableにする
            return [true]
          else
            raise UnexpectedValueError
          end
        end
      end
    end
  end
end
