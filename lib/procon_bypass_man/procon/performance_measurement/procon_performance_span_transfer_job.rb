# Bypassプロセスが収集したパフォーマンスメトリクスを、集計するためにmasterプロセスに転送するためジョブ
class ProconBypassMan::ProconPerformanceSpanTransferJob
  extend ProconBypassMan::Background::JobPerformable

  def self.perform(spans)
    ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.push(spans)
  end
end
