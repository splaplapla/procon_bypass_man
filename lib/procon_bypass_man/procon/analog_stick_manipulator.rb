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

  attr_accessor :manipulated_abs_x, :manipulated_abs_y

  def initialize(binary, method: )
    analog_stick = ProconBypassMan::Procon::AnalogStick.new(binary: binary)

    if method =~ /tilt_left_stick_(completely)_to_(left|right)/
      power_level = $1
      direction = $2

      case direction
      when 'left'
        self.manipulated_abs_x = 400
        self.manipulated_abs_y = analog_stick.abs_y
      when 'right'
        self.manipulated_abs_x = 3400
        self.manipulated_abs_y = analog_stick.abs_y
      end
    else
      warn "error stick manipulator"
      self.manipulated_abs_x = analog_stick.abs_x
      self.manipulated_abs_y = analog_stick.abs_y
    end
  end

  def to_binary
    Position.new(
      x: self.manipulated_abs_x,
      y: self.manipulated_abs_y,
    ).to_binary
  end
end
