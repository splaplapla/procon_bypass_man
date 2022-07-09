class ProconBypassMan::DelayJob
  extend ProconBypassMan::Background::JobPerformable

  def perform(span)
    ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.push(span)
  end
end
