# proconから取得したばかりのバイナリ
class ProconBypassMan::Domains::ProcessingProconBinary
  ALL_ZERO_BIT = ["0"].pack("H*").freeze

  # @param [String] binary
  def initialize(binary: )
    @binary = binary
  end

  # @return [String]
  def raw
    @binary
  end

  def unpack(...)
    @binary.unpack(...)
  end

  def [](index)
    @binary[index]
  end

  def []=(index, value)
    @binary[index] = value
  end

  def set_no_action!
    @binary[3] = ALL_ZERO_BIT
    @binary[4] = ALL_ZERO_BIT
    @binary[5] = ALL_ZERO_BIT
  end

  # @param [ProconBypassMan::Domains::ProcessingProconBinary]
  # @return [ProconBypassMan::Domains::ProcessingProconBinary]
  def merge!(target_binary)
    tb = [target_binary.raw].pack("H*")
    @binary[3] = tb[3]
    @binary[4] = tb[4]
    @binary[5] = tb[5]
    @binary[6] = tb[6]
    @binary[7] = tb[7]
    @binary[8] = tb[8]
    @binary[9] = tb[9]
    @binary[10] = tb[10]
    @binary[11] = tb[11]
    self
  end

  def pressed_button?(button)
    ProconBypassMan::PressButtonAware.new(@binary).pressed_button?(button)
  end

  def apply_left_analog_stick_cap(cap: )
    @binary[6..8] = ProconBypassMan::Procon::AnalogStickCap.new(@binary).capped_position(cap_hypotenuse: cap).to_binary
  end
end
