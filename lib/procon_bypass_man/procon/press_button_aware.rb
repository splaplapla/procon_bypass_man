class ProconBypassMan::PpressButtonAware
  def initialize(binary)
    @binary = binary
  end

  def pressed_button?(button)
    @binary[
      ::ProconBypassMan::Procon::ButtonCollection.load(button).byte_position
    ].unpack("H*").first.to_i(16).to_s(2).reverse[
      ::ProconBypassMan::Procon::ButtonCollection.load(button).bit_position
    ] == '1'
  end
end
