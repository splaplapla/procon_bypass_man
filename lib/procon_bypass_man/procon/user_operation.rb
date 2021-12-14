class ProconBypassMan::Procon
  class UserOperation
    attr_reader :binary

    ::ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP.each do |button, _value|
      define_method "pressed_#{button}?" do
        pressed_button?(button)
      end
    end

    # @param [String] binary
    def initialize(binary)
      unless binary.encoding.name == ASCII_ENCODING
        raise "おかしいです"
      end

      @binary = ProconBypassMan::Domains::ProcessingProconBinary.new(binary: binary)
    end

    ASCII_ENCODING = "ASCII-8BIT"

    def set_no_action!
      binary.set_no_action!
    end

    def apply_left_analog_stick_cap(cap: )
      binary.apply_left_analog_stick_cap(cap: cap)
    end

    def unpress_button(button)
      button_obj = ProconBypassMan::Procon::Button.new(button)
      return if not pressed_button?(button)

      value = binary.raw[button_obj.byte_position].unpack("H*").first.to_i(16) - (2**button_obj.bit_position)
      binary.raw[button_obj.byte_position] = ["%02X" % value.to_s].pack("H*")
    end

    def press_button(button)
      button_obj = ProconBypassMan::Procon::Button.new(button)
      return if pressed_button?(button)

      value = binary.raw[button_obj.byte_position].unpack("H*").first.to_i(16) + (2**button_obj.bit_position)
      binary.raw[button_obj.byte_position] = ["%02X" % value.to_s].pack("H*")
    end

    def press_button_only(button)
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

    # @return [void]
    def merge(target_binary)
      binary.merge!(
        ProconBypassMan::Domains::ProcessingProconBinary.new(binary: target_binary)
      )
    end

    # @param [Symbol]
    # @return [Boolean]
    def pressed_button?(button)
      binary.pressed_button?(button)
    end
  end
end
