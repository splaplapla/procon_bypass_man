module ProconBypassMan::Procon::PushedButtonHelper
  module Static
    def pushed_button?(button)
      binary[
        ::ProconBypassMan::Procon::ButtonCollection.load(button).byte_position
      ].unpack("H*").first.to_i(16).to_s(2).reverse[
        ::ProconBypassMan::Procon::ButtonCollection.load(button).bit_position
      ] == '1'
    end
  end

  module Dynamic
    @@compiled = false
    def compile_if_not_compile_yet!
      unless @@compiled
        ::ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP.each do |button, value|
          define_method "pushed_#{button}?" do
            pushed_button?(button)
          end
        end
      end
      @@compiled = true
    end
  end
end
