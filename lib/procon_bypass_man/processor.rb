class ProconBypassMan::Processor

  # @param [ProconBypassMan::Domains::InboundProconBinary] binary
  def initialize(binary)
    @binary = binary
  end

  # @return [String] 加工後の入力データ
  def process
    return @binary.raw unless @binary.user_operation_data?

    procon = ProconBypassMan::Procon.new(@binary.raw)
    procon.apply!
    procon.to_binary
  end
end
