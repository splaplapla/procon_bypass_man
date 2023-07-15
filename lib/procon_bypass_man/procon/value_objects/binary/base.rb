class ProconBypassMan::Domains::Binary::Base
  # @param [String] binary
  def initialize(binary: )
    @binary = binary
  end

  # @return [String]
  def binary
    raise NotImplementedError
  end

  # @return [String]
  def raw
    binary
  end

  def unpack
    binary.unpack("H*")
  end

  # @return [ProconBypassMan::ProconReader]
  def to_procon_reader
    ProconBypassMan::ProconReader.new(binary: binary)
  end
end
