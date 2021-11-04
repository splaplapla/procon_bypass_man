class ProconBypassMan::Procon::AnalogStick
  attr_accessor :neutral_position
  attr_accessor :bin_x, :bin_y

  def initialize(binary: )
    @neutral_position = ProconBypassMan::ButtonsSettingConfiguration.instance.neutral_position

    byte6 = binary[6].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")
    byte7 = binary[7].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")
    byte8 = binary[8].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")

    self.bin_x = "#{byte7[4..7]}#{byte6}"
    self.bin_y = "#{byte8}#{byte7[0..3]}"
  end

  def abs_x
    bin_x.to_i(2)
  end

  def abs_y
    bin_y.to_i(2)
  end

  def relative_x
    bin_x.to_i(2) - neutral_position.x
  end

  def relative_y
    bin_y.to_i(2) - neutral_position.y
  end
end
