class ProconBypassMan::Procon
  class UserOperation
    include LayerChangeable
    include PushedButtonHelper::Static
    extend PushedButtonHelper::Dynamic

    attr_reader :binary

    def initialize(binary)
      self.class.compile_if_not_compile_yet!
      @binary = binary
    end

    ASCII_ENCODING = "ASCII-8BIT"
    # @depilicate
    def binary=(binary)
      unless binary.encoding.name == ASCII_ENCODING
        raise "おかしいです"
      end
      @binary = binary
    end

    def set_no_action!
      zero = ["0"].pack("H*")
      binary[3] = zero
      binary[4] = zero
      binary[5] = zero
    end

    def unpress_button(button)
      byte_position = ButtonCollection.load(button).byte_position
      value = binary[byte_position].unpack("H*").first.to_i(16) - 2**ButtonCollection.load(button).bit_position
      binary[byte_position] = ["%02X" % value.to_s].pack("H*")
    end

    def press_button(button)
      byte_position = ButtonCollection.load(button).byte_position
      value = binary[byte_position].unpack("H*").first.to_i(16) + 2**ButtonCollection.load(button).bit_position
      binary[byte_position] = ["%02X" % value.to_s].pack("H*")
    end

    def press_button_only(button)
      [ProconBypassMan::Procon::Data::NO_ACTION.dup].pack("H*").tap do |no_action_binary|
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
      b = binary.dup
      (3..11).each do |byte_position|
        b[byte_position] = target_binary[byte_position]
      end
      self.binary = b
    end
  end
end
