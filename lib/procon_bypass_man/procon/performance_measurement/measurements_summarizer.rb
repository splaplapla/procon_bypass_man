class ProconBypassMan::Procon::PerformanceMeasurement::MeasurementsSummarizer
  class PerformanceMetric < Struct.new(:interval_from_previous_succeed_max,
                                       :interval_from_previous_succeed_p50,
                                       :write_time_max,
                                       :write_time_p50,
                                       :read_time_max,
                                       :read_time_p50,
                                       :time_taken_p50,
                                       :time_taken_p95,
                                       :time_taken_p99,
                                       :time_taken_max,
                                       :read_error_count,
                                       :write_error_count,
                                       :succeed_rate); end

  def initialize(spans: )
    @spans = spans
  end

  # @return [PerformanceMetric]
  def summarize
    sorted_write_time = @spans.map(&:write_time).sort
    sorted_read_time = @spans.map(&:read_time).sort

    sorted_time_taken = @spans.select(&:succeed).map(&:time_taken).sort
    sorted_interval_from_previous_succeed = @spans.select(&:succeed).map(&:interval_from_previous_succeed).sort

    interval_from_previous_succeed_max = sorted_interval_from_previous_succeed.last || 0
    interval_from_previous_succeed_p50 = percentile(sorted_list: sorted_interval_from_previous_succeed , percentile: 0.50)

    write_time_max = sorted_write_time.last || 0
    write_time_p50 = percentile(sorted_list: sorted_write_time , percentile: 0.50)

    read_time_max = sorted_read_time.last || 0
    read_time_p50 = percentile(sorted_list: sorted_read_time , percentile: 0.50)

    time_taken_p50 = percentile(sorted_list: sorted_time_taken, percentile: 0.50)
    time_taken_p95 = percentile(sorted_list: sorted_time_taken, percentile: 0.95)
    time_taken_p99 = percentile(sorted_list: sorted_time_taken, percentile: 0.99)
    time_taken_max = sorted_time_taken.last || 0

    total_read_error_count = @spans.map(&:read_error_count).sum
    total_write_error_count = @spans.map(&:write_error_count).sum
    succeed_rate =
      if @spans.length.zero?
        0
      else
        succeed_rate = (sorted_time_taken.length / @spans.length.to_f).floor(3)
      end

    PerformanceMetric.new(interval_from_previous_succeed_max,
                          interval_from_previous_succeed_p50,
                          write_time_max,
                          write_time_p50,
                          read_time_max,
                          read_time_p50,
                          time_taken_p50,
                          time_taken_p95,
                          time_taken_p99,
                          time_taken_max,
                          total_read_error_count,
                          total_write_error_count,
                          succeed_rate)
  end

  private

  # @param [Array<Numeric>] sorted_list
  # @param [Float] percentile
  # @return [Float]
  def percentile(sorted_list: , percentile: )
    return 0.0 if sorted_list.empty?
    values_sorted = sorted_list
    k = ((percentile*(values_sorted.length-1))+1).floor - 1
    f = ((percentile*(values_sorted.length-1))+1).modulo(1)
    return(values_sorted[k] + (f * (values_sorted[k+1] - values_sorted[k]))).floor(3)
  end
end
