class ProconBypassMan::PressButtonAware
  BIT_ON = '1'.freeze

  def initialize(binary)
    @binary = binary
  end

  # @param [Symbol]
  # @return [Boolean]
  def pressing_button?(button)
    button_obj = ProconBypassMan::Procon::Button.new(button)
    byte = @binary[button_obj.byte_position].unpack("C").first.to_s(2).reverse
    byte[button_obj.bit_position] == BIT_ON
  end
end
