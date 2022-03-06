class ProconBypassMan::Procon::AnalogStickManipulator
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

  attr_reader :direction, :power_level

  def initialize(binary, method: )
    if method =~ /tilt_(full)_(left|right)/
      @power_level = $1
      @direction = $2

      case @direction
      when :left
        @manipulated_x = 0
        @manipulated_y = 1808
      when :right
        @manipulated_x = 5000
        @manipulated_y = 1808
      end
    else
      warn "error stick manipulator"
      analog_stick = ProconBypassMan::Procon::AnalogStick.new(binary: binary)
      @manipulated_x = analog_stick.abs_x
      @manipulated_y = analog_stick.abs_y
    end
  end

  def to_binary
    Position.new(
      x: @manipulated_x,
      y: @manipulated_y,
    ).to_binary
  end
end