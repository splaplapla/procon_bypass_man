class ProconBypassMan::ReportProconPerformanceMeasurementsJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [ProconBypassMan::Procon::PerformanceMeasurement::MeasurementCollection] measurement_collection
  def self.perform(measurement_collection)
    return if measurement_collection.nil?

    collected_spans_size = measurement_collection.spans.size
    metric = ProconBypassMan::Procon::PerformanceMeasurement.summarize(
      spans: measurement_collection.spans
    )
    body = {
      timestamp: measurement_collection.timestamp_key,
      interval_from_previous_succeed_max: metric.interval_from_previous_succeed_max,
      interval_from_previous_succeed_p50: metric.interval_from_previous_succeed_p50,
      write_time_max: metric.write_time_max,
      write_time_p50: metric.write_time_p50,
      read_time_max: metric.read_time_max,
      read_time_p50: metric.read_time_p50,
      time_taken_max: metric.time_taken_max,
      time_taken_p50: metric.time_taken_p50,
      time_taken_p95: metric.time_taken_p95,
      time_taken_p99: metric.time_taken_p99,
      read_error_count: metric.read_error_count,
      write_error_count: metric.write_error_count,
      gc_count: metric.gc_count,
      succeed_rate: metric.succeed_rate,
      load_agv: ProconBypassMan::LoadAgv.new.get,
      collected_spans_size: collected_spans_size,
    }
    ProconBypassMan.logger.info(body)

    ProconBypassMan::ProconPerformanceHttpClient.new(
      path: path,
      server: api_server,
    ).post(body: body)
  end

  def self.path
    "/api/devices/#{ProconBypassMan.device_id}/procon_performance_metrics"
  end
end
