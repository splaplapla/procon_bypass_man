class ProconBypassMan::PressButtonAware
  def initialize(binary)
    @binary = binary
  end

  def pressed_button?(button)
    button_obj = ProconBypassMan::Procon::Button.new(button)
    @binary[
      button_obj.byte_position
    ].unpack("H*").first.to_i(16).to_s(2).reverse[
      button_obj.bit_position
    ] == '1'
  end
end
