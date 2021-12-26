# proconから取得したばかりのバイナリ
class ProconBypassMan::Domains::InboundProconBinary < ProconBypassMan::Domains::Binary::Base
  include ProconBypassMan::Domains::HasImmutableBinary

  # @return [String]
  def raw
    binary.dup
  end

  def unpack
    binary.unpack("H*")
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
