class ProconBypassMan::Domains::Binary::Base
  # @param [String] binary
  def initialize(binary: )
    @binary = binary
  end

  # @return [String] バイナリ
  def binary
    raise NotImplementedError
  end
end
