module ProconBypassMan::Procon::PerformanceMeasurement; end

require 'benchmark'
require 'procon_bypass_man/procon/performance_measurement/span_queue'
require 'procon_bypass_man/procon/performance_measurement/queue_over_process'

module ProconBypassMan::Procon::PerformanceMeasurement
  class PerformanceMetrics < Struct.new(:time_taken_p50,
                                        :time_taken_p95,
                                        :time_taken_p99,
                                        :time_taken_max,
                                        :read_error_count,
                                        :write_error_count); end

  class MeasurementsSummarizer
    def initialize(measurements: )
      @measurements = measurements
    end

    # @return [PerformanceMetrics]
    def summarize
      sorted_time_taken = @measurements.map(&:time_taken).sort
      time_taken_p50 = percentile(sorted_list: sorted_time_taken, percentile: 0.50)
      time_taken_p95 = percentile(sorted_list: sorted_time_taken, percentile: 0.95)
      time_taken_p99 = percentile(sorted_list: sorted_time_taken, percentile: 0.99)
      time_taken_max = sorted_time_taken.last || 0
      total_read_error_count = @measurements.map(&:read_error_count).sum
      total_write_error_count = @measurements.map(&:write_error_count).sum
      PerformanceMetrics.new(time_taken_p50, time_taken_p95, time_taken_p99, time_taken_max, total_read_error_count, total_write_error_count)
    end

    private

    # @param [Array<any>]
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

  class PerformanceSpan
    attr_accessor :time_taken
    attr_reader :write_error_count, :read_error_count

    def initialize
      @write_error_count = 0
      @read_error_count = 0
      @time_taken = 0.0
    end

    def record_read_error
      @read_error_count += 1
    end

    def record_write_error
      @write_error_count += 1
    end
  end

  # measureをして、measureの結果をためる
  # @return [void]
  def self.measure(&block)
    unless ProconBypassMan.config.enable_procon_performance_measurement?
      block.call(PerformanceSpan.new)
      return
    end

    span = PerformanceSpan.new
    span.time_taken = Benchmark.realtime { block.call(span) }
    ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.push(span)
  end

  # @return [MeasurementCollection, NilClass]
  # bypassしているプロセスから呼ばれる
  def self.pop_measurement_collection
    ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.pop
  end

  # @param [MeasurementCollection] measurements
  # @return [PerformanceMetrics]
  # jobから呼ばれる予定
  def self.summarize(measurements: )
    MeasurementsSummarizer.new(measurements: measurements).summarize
  end
end
