class ProconBypassMan::ProconPerformanceSpanTransferJob
  extend ProconBypassMan::Background::JobPerformable

  def self.perform(spans)
    ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.push(spans)
  end
end
