class ProconBypassMan::DelayJob
  extend ProconBypassMan::Background::JobPerformable

  def self.perform(span)
    ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.push(span)
  end
end
