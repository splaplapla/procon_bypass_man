class ProconBypassMan::Procon::DebugDumper
  def initialize(binary: )
    @binary = binary
  end

  def dump_analog_sticks
    fi = @binary[6..8].unpack("H*").first.to_i(16).to_s(2).rjust(18, "0")
    se = @binary[9..11].unpack("H*").first.to_i(16).to_s(2).rjust(18, "0")
    th = @binary[12..14].unpack("H*").first.to_i(16).to_s(2).rjust(18, "0")
    ProconBypassMan.logger.debug "6..8: #{fi}"
    ProconBypassMan.logger.debug "9..11: #{se}"
    ProconBypassMan.logger.debug "12..14: #{th}"
  end
end
