# n秒間sleepしつつ、mainスレッドをm秒間隔で動かしたい時に使う
class ProconBypassMan::CycleSleep
  attr_accessor :cycle_interval, :execution_cycle

  def initialize(cycle_interval: , execution_cycle: )
    @cycle_interval = cycle_interval
    @execution_cycle = execution_cycle
    @counter = 0
  end

  def sleep_or_execute
    result = nil
    if @counter >= @execution_cycle
      @counter = 0
      result = yield
    else
      @counter += 1
    end
    sleep(@cycle_interval)
    return result
  end
end
