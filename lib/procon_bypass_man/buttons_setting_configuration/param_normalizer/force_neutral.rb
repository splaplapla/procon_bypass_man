module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class ForceNeutral
        attr_reader :force_neutral

        def initialize(force_neutral)
          @force_neutral = force_neutral
        end

        def to_value!
          case force_neutral
          when Integer, TrueClass
            raise UnSupportValueError
          when Symbol, String
            return [force_neutral.to_sym]
          when Array
            return force_neutral.map(&:to_sym).uniq
          when FalseClass, NilClass
            return nil
          else
            raise UnexpectedValueError
          end
        end
      end
    end
  end
end
