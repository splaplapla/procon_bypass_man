class ProconBypassMan::Processor
  # @return [String] binary
  def initialize(binary)
    @binary = binary
  end

  # @return [String]
  def process
    # 入力データ
    if @binary[0] == "\x30".b
    end

    @binary
  end
end
