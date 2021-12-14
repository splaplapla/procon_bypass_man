# proconから取得したばかりのバイナリ
class ProconBypassMan::Domains::InboundProconBinary
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

  # @return [ProconBypassMan::ProconReader]
  def to_procon_reader
    ProconBypassMan::ProconReader.new(binary: @binary).freeze
  end

  # @return [Boolean]
  def user_operation_data?
    @binary[0] == "\x30".b
  end
end
