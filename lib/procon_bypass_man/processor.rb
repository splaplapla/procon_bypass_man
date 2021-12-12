class ProconBypassMan::Processor

  # @param [ProconBypassMan::Domains::InboundProconBinary] binary
  def initialize(binary)
    @binary = binary
  end

  # @return [String] 加工後の入力データ
  def process
    return @binary.raw unless @binary.input_data_from_user?

    procon = ProconBypassMan::Procon.new(@binary.raw)
    procon.apply!
    procon.to_binary
  end
end
