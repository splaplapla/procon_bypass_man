class ProconBypassMan::ReportProconPerformanceMeasurementsJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasExternalApiSetting

  def self.perform
    measurement_collection = ProconBypassMan::Procon::PerformanceMeasurement.pop_measurement_collection
    metrics = ProconBypassMan::Procon::PerformanceMeasurement.summarize(measurements: measurement_collection.measurements)
    body = {
      timestamp: timestamp_key,
      time_taken_max:metrics.time_taken_max,
      time_taken_p50: metrics.time_taken_p50,
      time_taken_p99: metrics.time_taken_p99,
      time_taken_p95: metrics.time_taken_p95,
      read_error_count: metrics.read_error_count,
      write_error_count: metrics.write_error_count,
      load_agv: ProconBypassMan::LoadAgv.new.get,
    }

    ProconBypassMan::ReportHttpClient.new(
      path: path,
      server_pool: server_pool,
    ).post(body: body)
  end

  def self.path
    "/api/devices/#{ProconBypassMan.device_id}/procon_performance_metrics"
  end
end
