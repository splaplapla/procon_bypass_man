module ProconBypassMan::Procon::PushedButtonHelper
  module Dynamic
    @@compiled = false
    def compile_if_not_compile_yet!
      unless @@compiled
        ::ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP.each do |button, _value|
          define_method "pressed_#{button}?" do
            pressed_button?(button)
          end
        end
      end
      @@compiled = true
    end
  end
end
