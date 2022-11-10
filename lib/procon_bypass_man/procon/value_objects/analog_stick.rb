# frozen_string_literal: true

class ProconBypassMan::Procon::AnalogStick
  attr_accessor :neutral_position
  attr_writer :bin_x, :bin_y

  def initialize(binary: )
    @neutral_position = ProconBypassMan::ButtonsSettingConfiguration.instance.neutral_position
    bytes = binary[ProconBypassMan::Procon::ButtonCollection::LEFT_ANALOG_STICK.fetch(:byte_position)]
    byte6, byte7, byte8 = bytes.each_char.map { |x| x.unpack("C").first.to_s(2).rjust(8, "0") }

    self.bin_x = "#{byte7[4..7]}#{byte6}"
    self.bin_y = "#{byte8}#{byte7[0..3]}"
    freeze
  end

  def abs_x
    @bin_x.to_i(2)
  end

  def abs_y
    @bin_y.to_i(2)
  end

  def relative_x
    @bin_x.to_i(2) - neutral_position.x
  end

  def relative_y
    @bin_y.to_i(2) - neutral_position.y
  end

  def relative_hypotenuse
    Math.sqrt((relative_x**2) + (relative_y**2)).floor(6)
  end

  # @return [Array<Integer>] 相対的なx, yの座標
  def to_a
    [relative_x, relative_y]
  end
end
