class ProconBypassMan::Procon
  class UserOperation
    attr_reader :binary

    ::ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP.each do |button, _value|
      define_method "pressed_#{button}?" do
        pressed_button?(button)
      end
    end

    def initialize(binary)
      unless binary.encoding.name == ASCII_ENCODING
        raise "おかしいです"
      end
      @binary = binary
    end

    ALL_ZERO_BIT = ["0"].pack("H*").freeze
    ASCII_ENCODING = "ASCII-8BIT"

    def set_no_action!
      binary[3] = ALL_ZERO_BIT
      binary[4] = ALL_ZERO_BIT
      binary[5] = ALL_ZERO_BIT
    end

    def apply_left_analog_stick_cap(cap: )
      binary[6..8] = ProconBypassMan::Procon::AnalogStickCap.new(binary).capped_position(cap_hypotenuse: cap).to_binary
    end

    def unpress_button(button)
      button_obj = ProconBypassMan::Procon::Button.new(button)
      return if not pressed_button?(button)

      value = binary[button_obj.byte_position].unpack("H*").first.to_i(16) - (2**button_obj.bit_position)
      binary[button_obj.byte_position] = ["%02X" % value.to_s].pack("H*")
    end

    def press_button(button)
      button_obj = ProconBypassMan::Procon::Button.new(button)
      return if pressed_button?(button)

      value = binary[button_obj.byte_position].unpack("H*").first.to_i(16) + (2**button_obj.bit_position)
      binary[button_obj.byte_position] = ["%02X" % value.to_s].pack("H*")
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

    def merge(target_binary: )
      tb = [target_binary].pack("H*")
      binary[3] = tb[3]
      binary[4] = tb[4]
      binary[5] = tb[5]
      binary[6] = tb[6]
      binary[7] = tb[7]
      binary[8] = tb[8]
      binary[9] = tb[9]
      binary[10] = tb[10]
      binary[11] = tb[11]
      self.binary
    end

    def pressed_button?(button)
      ProconBypassMan::PpressButtonAware.new(binary).pressed_button?(button)
    end
  end
end
