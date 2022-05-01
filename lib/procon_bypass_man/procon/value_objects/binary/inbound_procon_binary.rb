# proconから取得したばかりのバイナリ
class ProconBypassMan::Domains::InboundProconBinary < ProconBypassMan::Domains::Binary::Base
  include ProconBypassMan::Domains::HasImmutableBinary

  # @return [Boolean]
  def user_operation_data?
    binary[0] == "\x30".b
  end

  # @return [Boolean]
  def rumble_data?
    binary[0] == "\x10".b
  end
end
