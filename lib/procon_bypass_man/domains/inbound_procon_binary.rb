# proconから取得したばかりのバイナリ
class ProconBypassMan::Domains::InboundProconBinary
  include ProconBypassMan::Domains::HasImmutableBinary

  # @param [String] binary
  def initialize(binary: )
    @binary = binary
  end

  # @return [String]
  def raw
    binary.dup
  end

  def unpack(...)
    binary.unpack(...)
  end

  # @return [ProconBypassMan::ProconReader]
  def to_procon_reader
    ProconBypassMan::ProconReader.new(binary: binary)
  end

  # @return [Boolean]
  def user_operation_data?
    binary[0] == "\x30".b
  end
end
