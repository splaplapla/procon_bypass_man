module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class Button
        attr_reader :button

        def initialize(button)
          @button = button
        end

        def to_value!
          case button
          when TrueClass, FalseClass, NilClass, Array, Integer
            raise UnSupportValueError
          when Symbol, String
            unless !!ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP[button.to_sym]
              raise UnexpectedValueError
            end

            return button.to_sym
          else
            raise UnexpectedValueError
          end
        end
      end
    end
  end
end
