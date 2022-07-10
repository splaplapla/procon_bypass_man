class ProconBypassMan::ReportProconPerformanceMeasurementsJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [ProconBypassMan::Procon::PerformanceMeasurement::MeasurementCollection] measurement_collection
  def self.perform(measurement_collection)
    return if measurement_collection.nil?

    metric = ProconBypassMan::Procon::PerformanceMeasurement.summarize(
      spans: measurement_collection.spans
    )
    body = {
      timestamp: measurement_collection.timestamp_key,
      time_taken_max: metric.time_taken_max,
      time_taken_p50: metric.time_taken_p50,
      time_taken_p95: metric.time_taken_p95,
      time_taken_p99: metric.time_taken_p99,
      read_error_count: metric.read_error_count,
      write_error_count: metric.write_error_count,
      load_agv: ProconBypassMan::LoadAgv.new.get,
    }

    ProconBypassMan::ProconPerformanceHttpClient.new(
      path: path,
      server_pool: server_pool,
    ).post(body: body)
  end

  def self.path
    "/api/devices/#{ProconBypassMan.device_id}/procon_performance_metrics"
  end
end
