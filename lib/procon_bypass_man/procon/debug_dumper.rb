class ProconBypassMan::Procon::DebugDumper
  def initialize(binary: )
    @binary = binary
  end

  def dump_analog_sticks
    bin6 = @binary[6].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")
    bin7 = @binary[7].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")
    bin8 = @binary[8].unpack("H*").first.to_i(16).to_s(2).rjust(8, "0")

    x = "#{bin7[4..7]}#{bin6}"
    y = "#{bin8}#{bin7[0..3]}"
    ProconBypassMan.logger.debug "x: #{x}, val: #{x.to_i(2)}"
    ProconBypassMan.logger.debug "y: #{y}, val: #{y.to_i(2)}"
  end
end
