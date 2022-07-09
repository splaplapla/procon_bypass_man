class ProconBypassMan::Procon::PerformanceMeasurement::SpanTransferBuffer
  include Singleton

  def initialize
    @buff = []
  end

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
    @buff.length > 200
  end
end
