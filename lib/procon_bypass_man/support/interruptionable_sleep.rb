# n秒間sleepしつつ、mainスレッドをm秒間隔で動かしたい時に使う
class ProconBypassMan::InterruptionableSleep
  def initialize(cycle_interval: , execution_cycle: )
    @cycle_interval = cycle_interval
    @execution_cycle = execution_cycle
    @counter = 0
  end

  def sleep_or_execute
    if @counter >= @execution_cycle
      @counter = 0
      return yield
    else
      sleep(@cycle_interval)
      @counter += 1
      return nil
    end
  end
end
