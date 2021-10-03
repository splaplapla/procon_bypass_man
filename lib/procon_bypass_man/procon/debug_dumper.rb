class ProconBypassMan::Procon::DebugDumper
  def initialize(binary: )
    @binary = binary
  end

  def dump_analog_sticks
    byte6 = @binary[6].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")
    byte7 = @binary[7].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")
    byte8 = @binary[8].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")

    x = "#{byte7[4..7]}#{byte6}"
    y = "#{byte8}#{byte7[0..3]}"
    ProconBypassMan.logger.debug "x: #{x}, val: #{x.to_i(2)}"
    ProconBypassMan.logger.debug "y: #{y}, val: #{y.to_i(2)}"
  end
end
