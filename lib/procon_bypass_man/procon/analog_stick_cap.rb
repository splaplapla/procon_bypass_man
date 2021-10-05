class ProconBypassMan::Procon::AnalogStickCap
  class Position
    attr_accessor :x, :y

    def initialize(x:, y:)
      @x = x.to_i
      @y = y.to_i
    end

    def to_binary
      analog_stick_data = [
        (@x & "0xff".to_i(16)),
        ((@y << 4) & "0xf0".to_i(16)) | ((@x >> 8) & "0x0f".to_i(16)),
        (@y >> 4) & "0xff".to_i(16),
      ]
      hex = analog_stick_data.map{ |x| x.to_s(16).ljust(2, "0") }.join
      [hex].pack("H*")
    end
  end

  attr_accessor :bin_x, :bin_y
  attr_accessor :neutral_position

  def initialize(binary)
    @neutral_position = { x: 2124, y: 1807 }
    @binary = binary

    byte6 = binary[6].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")
    byte7 = binary[7].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")
    byte8 = binary[8].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")

    self.bin_x = "#{byte7[4..7]}#{byte6}"
    self.bin_y = "#{byte8}#{byte7[0..3]}"
  end

  # @return [ProconBypassMan::Procon::AnalogStickCap::Position]
  def capped_position(cap_hypotenuse: )
    if hypotenuse > cap_hypotenuse
      relative_capped_x = cap_hypotenuse * Math.cos(rad * Math::PI / 180).abs
      relative_capped_y = cap_hypotenuse * Math.sin(rad * Math::PI / 180).abs
      relative_capped_x = -(relative_capped_x.abs) if relative_x.negative?
      relative_capped_y = -(relative_capped_y.abs) if relative_y.negative?
      return Position.new(
        x: relative_capped_x + neutral_position[:x],
        y: relative_capped_y + neutral_position[:y],
      )
    else
      return position
    end
  end

  # @return [ProconBypassMan::Procon::AnalogStickCap::Position]
  def position
    Position.new(x: abs_x, y: abs_y)
  end

  # 0, 0からのx
  def abs_x
    bin_x.to_i(2)
  end

  # 0, 0からのy
  def abs_y
    bin_y.to_i(2)
  end

  def relative_x
    bin_x.to_i(2) - neutral_position[:x]
  end

  def relative_y
    bin_y.to_i(2) - neutral_position[:y]
  end

  # @deprecated
  def x; relative_x; end
  def y; relative_y; end

  def rad
    (
      Math.atan(y / x.to_f) * 180 / Math::PI
    ).floor(6)
  end

  def hypotenuse
    Math.sqrt(x**2 + y**2).floor(6)
  end
end
