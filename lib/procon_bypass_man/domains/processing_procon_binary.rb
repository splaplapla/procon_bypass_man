# バイナリの書き換えのみをする
class ProconBypassMan::Domains::ProcessingProconBinary
  include ProconBypassMan::Domains::HasMutableBinary

  ALL_ZERO_BIT = ["0"].pack("H*").freeze

  # @param [String] binary
  def initialize(binary: )
    @binary = binary
  end

  # @return [String]
  def raw
    binary
  end

  def unpack
    binary.unpack("H*")
  end

  def set_no_action!
    binary[3] = ALL_ZERO_BIT
    binary[4] = ALL_ZERO_BIT
    binary[5] = ALL_ZERO_BIT
  end

  # @param [ProconBypassMan::Domains::ProcessingProconBinary]
  # @return [ProconBypassMan::Domains::ProcessingProconBinary]
  def write_as_merge!(target_binary)
    tb = [target_binary.raw].pack("H*")
    binary[3] = tb[3]
    binary[4] = tb[4]
    binary[5] = tb[5]
    binary[6] = tb[6]
    binary[7] = tb[7]
    binary[8] = tb[8]
    binary[9] = tb[9]
    binary[10] = tb[10]
    binary[11] = tb[11]
    self
  end

  def write_as_press_button(button)
    button_obj = ProconBypassMan::Procon::Button.new(button)
    value = binary[button_obj.byte_position].unpack("H*").first.to_i(16) + (2**button_obj.bit_position)
    binary[button_obj.byte_position] = ["%02X" % value.to_s].pack("H*")
  end

  def write_as_unpress_button(button)
    button_obj = ProconBypassMan::Procon::Button.new(button)
    value = binary[button_obj.byte_position].unpack("H*").first.to_i(16) - (2**button_obj.bit_position)
    binary[button_obj.byte_position] = ["%02X" % value.to_s].pack("H*")
  end

  def write_as_press_button_only(button)
    button_obj = ProconBypassMan::Procon::Button.new(button)
    [ProconBypassMan::Procon::Consts::NO_ACTION.dup].pack("H*").tap do |no_action_binary|
      byte_position = button_obj.byte_position
      value = 2**button_obj.bit_position
      no_action_binary[byte_position] = ["%02X" % value.to_s].pack("H*")
      binary[3] = no_action_binary[3]
      binary[4] = no_action_binary[4]
      binary[5] = no_action_binary[5]
    end
  end

  def write_as_apply_left_analog_stick_cap(cap: )
    binary[6..8] = ProconBypassMan::Procon::AnalogStickCap.new(binary).capped_position(cap_hypotenuse: cap).to_binary
  end
end
