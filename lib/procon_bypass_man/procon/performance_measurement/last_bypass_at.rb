class ProconBypassMan::Procon::PerformanceMeasurement::LastBypassAt
  include Singleton

  attr_accessor :mutex, :last_bypass_at

  def initialize
    self.mutex = Mutex.new
    self.last_bypass_at = Time.now
  end

  def self.touch(&block)
    instance.mutex.synchronize do
      block.call(Time.now - instance.last_bypass_at)
      instance.last_bypass_at = Time.now
    end
  end
end
