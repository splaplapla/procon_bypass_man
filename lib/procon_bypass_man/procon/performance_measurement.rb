module ProconBypassMan::Procon::PerformanceMeasurement; end

require 'benchmark'
require 'procon_bypass_man/procon/performance_measurement/measurements_summarizer'
require 'procon_bypass_man/procon/performance_measurement/span_queue'
require 'procon_bypass_man/procon/performance_measurement/queue_over_process'

module ProconBypassMan::Procon::PerformanceMeasurement
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
  # @return [ProconBypassMan::Procon::PerformanceMeasurement::MeasurementsSummarizer::PerformanceMetric]
  # jobから呼ばれる予定
  def self.summarize(measurements: )
    ProconBypassMan::Procon::PerformanceMeasurement::MeasurementsSummarizer.new(measurements: measurements).summarize
  end
end
