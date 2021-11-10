class ProconBypassMan::Procon
  class UserOperation
    include LayerChangeable

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

    ZERO_BIT = ["0"].pack("H*").freeze
    ASCII_ENCODING = "ASCII-8BIT"

    # @depilicate
    def binary=(binary)
      unless binary.encoding.name == ASCII_ENCODING
        raise "おかしいです"
      end
      @binary = binary
    end

    def set_no_action!
      binary[3] = ZERO_BIT
      binary[4] = ZERO_BIT
      binary[5] = ZERO_BIT
    end

    def unpress_button(button)
      return if not pressed_button?(button)

      byte_position = ButtonCollection.load(button).byte_position
      value = binary[byte_position].unpack("H*").first.to_i(16) - (2**ButtonCollection.load(button).bit_position)
      binary[byte_position] = ["%02X" % value.to_s].pack("H*")
    end

    def apply_left_analog_stick_cap(cap: )
      binary[6..8] = ProconBypassMan::Procon::AnalogStickCap.new(binary).capped_position(cap_hypotenuse: cap).to_binary
    end

    def press_button(button)
      return if pressed_button?(button)

      byte_position = ButtonCollection.load(button).byte_position
      value = binary[byte_position].unpack("H*").first.to_i(16) + (2**ButtonCollection.load(button).bit_position)
      binary[byte_position] = ["%02X" % value.to_s].pack("H*")
    end

    def press_button_only(button)
      [ProconBypassMan::Procon::Consts::NO_ACTION.dup].pack("H*").tap do |no_action_binary|
        ButtonCollection.load(button).byte_position
        byte_position = ButtonCollection.load(button).byte_position
        value = 2**ButtonCollection.load(button).bit_position
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
