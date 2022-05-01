class ProconBypassMan::RumbleBinary
  # @param [String] binary
  def initialize(binary: )
    @binary = binary
  end

  def unpack
    @binary.unpack("H*")
  end

  def noop!
    @binary = ProconBypassMan::SuppressRumble.new(binary: @binary).execute
  end

  def raw
    @binary
  end
end
