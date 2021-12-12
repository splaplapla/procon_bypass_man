# proconから取得したばかりのバイナリ
class ProconBypassMan::Domains::ProcessingProconBinary
  # @param [String] binary
  def initialize(binary: )
    @binary = binary
  end

  # @return [String]
  def raw
    @binary
  end

  def unpack(...)
    @binary.unpack(...)
  end
end
