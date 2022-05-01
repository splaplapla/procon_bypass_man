class ProconBypassMan::RumbleBinary
  # @param [String] binary
  def initialize(binary: )
    @binary = binary
  end

  def unpack
    @binary.unpack("H*")
  end

  def noop!
  end

  def raw
    @binary
  end
end
