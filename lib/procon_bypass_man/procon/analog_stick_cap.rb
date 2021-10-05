class ProconBypassMan::Procon::AnalogStickCap
  attr_accessor :bin_x, :bin_y

  def initialize(binary)
    @binary = binary

    byte6 = @binary[6].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")
    byte7 = @binary[7].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")
    byte8 = @binary[8].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")

    self.bin_x = "#{byte7[4..7]}#{byte6}"
    self.bin_y = "#{byte8}#{byte7[0..3]}"
  end

  # @return [String]
  def capped_binary_values(cap_x: , cap_y: )
    if x > cap_x.first
      new_x = cap_x.first
    end
    if x < cap_x.last
      new_x = cap_x.last
    end
    if y > cap_y.first
      new_y = cap_y.first
    end
    if y < cap_y.last
      new_y = cap_y.last
    end
    to_binary(new_x: new_x || x, new_y: new_y || y)
  end

  def radian
    (
      Math.asin(x / y.to_f) * Math::PI
    ).floor(6)
  end

  # @return [String]
  def binary_values
    to_binary(new_x: x, new_y: y)
  end

  def x
    bin_x.to_i(2)
  end

  def y
    bin_y.to_i(2)
  end

  private

  def to_binary(new_x: , new_y: )
    analog_stick_data = [
      (new_x & "0xff".to_i(16)),
      ((new_y << 4) & "0xf0".to_i(16)) | ((new_x >> 8) & "0x0f".to_i(16)),
      t = (new_y >> 4) & "0xff".to_i(16),
    ]
    hex = analog_stick_data.map{ |x| x.to_s(16) }.join
    [hex].pack("H*")
  end
end
