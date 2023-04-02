class ProconBypassMan::Processor

  # @param [ProconBypassMan::Domains::InboundProconBinary] binary
  def initialize(binary)
    @binary = binary
  end

  # @param [ProconBypassMan::ExternalInput::ExternalData, NilClass] external_input_data
  # @return [String] 加工後の入力データ
  def process(external_input_data: nil)
    return @binary.raw unless @binary.user_operation_data?

    procon = ProconBypassMan::Procon.new(@binary.raw)
    procon.apply!
    procon.to_binary(external_input_data: external_input_data)
  end
end
