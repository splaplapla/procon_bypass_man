class ProconBypassMan::AnalogStickPosition
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
