module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class OpenMacroSteps
        attr_reader :steps

        def initialize(steps)
          @steps = steps
        end

        def to_value!
          case steps
          when Integer, TrueClass, FalseClass, NilClass
            raise UnSupportValueError
          when String, Symbol
            return [steps.to_sym]
          when Array
            return steps.map(&:to_sym)
          else
            raise UnexpectedValueError
          end
        end
      end
    end
  end
end
