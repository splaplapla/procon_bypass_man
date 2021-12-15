# バイナリの書き換えのみをする
class ProconBypassMan::Domains::ProcessingProconBinary
  include ProconBypassMan::Domains::HasMutableBinary

  ALL_ZERO_BIT = ["0"].pack("H*").freeze

  # @param [String] binary
  def initialize(binary: )
    @binary = binary or raise("need binary")
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
  # ボタンだけマージする
  def write_as_merge!(target_binary)
    current_buttons = ProconBypassMan::ProconReader.new(binary: binary).pressed
    target_buttons = ProconBypassMan::ProconReader.new(binary: target_binary.raw).pressed

    set_no_action!
    (current_buttons + target_buttons).uniq.each do |button|
      write_as_press_button(button)
    end
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
    set_no_action!
    write_as_press_button(button)
  end

  # @param [Integer]
  def write_as_apply_left_analog_stick_cap(cap: )
    analog_stick_cap = ProconBypassMan::Procon::AnalogStickCap.new(binary)
    binary[6..8] = analog_stick_cap.capped_position(cap_hypotenuse: cap).to_binary
  end
end
