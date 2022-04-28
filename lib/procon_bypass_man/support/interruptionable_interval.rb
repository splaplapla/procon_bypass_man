class ProconBypassMan::InterruptionableInterval
  # n秒間sleepしたいけどmainスレッドをm秒間隔で動かしたい時に使う
  def initialize(cycle_interval: 1, executing_interval: 10)
    @cycle_interval = cycle_interval
    @executing_interval = executing_interval
  end

  def sleep_or_execute
  end
end
