module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class IfPressed
        attr_reader :value

        def initialize(value, set_to_allow_falsy: , allow_true_class: )
          @value = value
          @allow_true_class = allow_true_class
          @set_to_allow_falsy = set_to_allow_falsy
        end

        def to_value!
          case value
          when Integer
            raise UnSupportValueError
          when TrueClass
            if @allow_true_class
              return [value]
            else
              raise UnSupportValueError
            end
          when Symbol, String
            return [value.to_sym]
          when Array
            return value.map(&:to_sym).uniq
          when FalseClass, NilClass
            if @set_to_allow_falsy
              return false
            end
          else
            raise UnexpectedValueError
          end
        end
      end
    end
  end
end
