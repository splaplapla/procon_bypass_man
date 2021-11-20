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
      hex = analog_stick_data.map{ |x| x.to_s(16).rjust(2, "0") }.join
      [hex].pack("H*")
    end
  end

  def initialize(binary)
    @binary = binary
    @analog_stick = ProconBypassMan::Procon::AnalogStick.new(binary: binary)
  end

  # @return [ProconBypassMan::Procon::AnalogStickCap::Position]
  def capped_position(cap_hypotenuse: )
    if hypotenuse > cap_hypotenuse
      relative_capped_x = cap_hypotenuse * Math.cos(rad * Math::PI / 180).abs
      relative_capped_y = cap_hypotenuse * Math.sin(rad * Math::PI / 180).abs
      relative_capped_x = -(relative_capped_x.abs) if relative_x.negative?
      relative_capped_y = -(relative_capped_y.abs) if relative_y.negative?
      return Position.new(
        x: relative_capped_x + @analog_stick.neutral_position.x,
        y: relative_capped_y + @analog_stick.neutral_position.y,
      )
    else
      return position
    end
  end

  # @return [ProconBypassMan::Procon::AnalogStickCap::Position]
  def position
    Position.new(x: abs_x, y: abs_y)
  end

  def abs_x; @analog_stick.abs_x; end # 0, 0からのx
  def abs_y; @analog_stick.abs_y; end # 0, 0からのy
  def relative_x; @analog_stick.relative_x; end
  def relative_y; @analog_stick.relative_y; end

  # @deprecated
  def x; relative_x; end
  def y; relative_y; end

  def rad
    (
      Math.atan(relative_y / relative_x.to_f) * 180 / Math::PI
    ).floor(6)
  end

  def hypotenuse
    Math.sqrt((relative_x**2) + (relative_y**2)).floor(6)
  end
end
