class ProconBypassMan::SuppressRumble
  # @param [String] binary
  def initialize(binary: )
    @binary = binary
  end

  # @return [String]
  def execute
    new_raw = ["100c0001404000014040"].pack("H*")
    new_raw[1] = @binary[1]
    new_raw
  end
end
