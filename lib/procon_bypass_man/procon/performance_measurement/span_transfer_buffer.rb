class ProconBypassMan::Procon::PerformanceMeasurement::SpanTransferBuffer
  include Singleton

  def initialize
    @buff = []
  end

  # @param [Span]
  # @return [void]
  def push_and_run_block_if_buffer_over(value, &block)
    push(value)
    return unless buffer_over?

    block.call(spans)
    clear
  end

  private

  def spans
    @buff
  end

  def clear
    @buff.clear
  end

  def push(value)
    @buff << value
  end

  def buffer_over?
    @buff.length > max_buffer
  end

  def max_buffer
    400
  end
end
