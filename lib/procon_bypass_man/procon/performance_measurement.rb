module ProconBypassMan::Procon::PerformanceMeasurement; end

require 'benchmark'
require 'procon_bypass_man/procon/performance_measurement/measurements_summarizer'
require 'procon_bypass_man/procon/performance_measurement/span_queue'
require 'procon_bypass_man/procon/performance_measurement/procon_performance_span_transfer_job'
require 'procon_bypass_man/procon/performance_measurement/span_transfer_buffer'
require 'procon_bypass_man/procon/performance_measurement/measurement_collection'
require 'procon_bypass_man/procon/performance_measurement/queue_over_process'
require 'procon_bypass_man/procon/performance_measurement/last_bypass_at'

module ProconBypassMan::Procon::PerformanceMeasurement
  class PerformanceSpan
    attr_accessor :time_taken, :succeed, :interval_from_previous_succeed, :gc_count, :gc_time
    attr_reader :write_error_count, :read_error_count, :write_time, :read_time

    def initialize
      @write_error_count = 0
      @read_error_count = 0
      @time_taken = 0.0
      @succeed = nil
      @interval_from_previous_succeed = nil
      @custom_metric = {}
      @write_time = 0.0
      @read_time = 0.0
      @gc_time = 0.0
    end

    def record_read_error
      @read_error_count += 1
    end

    def record_write_error
      @write_error_count += 1
    end

    def record_write_time(&block)
      result = nil
      @write_time = Benchmark.realtime { result = block.call }
      return result
    end

    def record_read_time(&block)
      @read_time = Benchmark.realtime { block.call }
    end
  end

  # 全部送ると負荷になるので適当にまびく
  def self.is_not_measure_with_random_or_if_fast(span: )
    return false if span.time_taken > 0.1
    return true if rand(10) != 0 # 9/10は捨てる
    return false
  end

  # measureをして、measureの結果をためる
  # @return [Boolean] 成功したか. テスト時に戻り値を使いたい
  def self.measure(&bypass_process_block)
    unless ProconBypassMan.config.enable_procon_performance_measurement?
      bypass_process_block.call(PerformanceSpan.new)
      return
    end

    if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.1.0")
      snapshot_gc_time = GC.stat(:time) / 1000.0
    end
    snapshot_gc_count = GC.count
    span = PerformanceSpan.new

    span.time_taken = Benchmark.realtime {
      span.succeed = bypass_process_block.call(span)
    }.floor(3)

    return if is_not_measure_with_random_or_if_fast(span: span)

    if span.succeed
      ProconBypassMan::Procon::PerformanceMeasurement::LastBypassAt.touch do |interval_from_previous_succeed|
        span.interval_from_previous_succeed = interval_from_previous_succeed.floor(3)
      end
    end

    (GC.count - snapshot_gc_count).tap do |increased_gc_count|
      span.gc_count = increased_gc_count
    end

    if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.1.0")
      ((GC.stat(:time) / 1000.0) - snapshot_gc_time).tap do |increased_time|
        span.gc_time = increased_time
      end
    end

    # measureするたびにperform_asyncしているとjob queueが詰まるのでbufferingしている
    ProconBypassMan::Procon::PerformanceMeasurement::SpanTransferBuffer.instance.push_and_run_block_if_buffer_over(span) do |spans|
      ProconBypassMan::ProconPerformanceSpanTransferJob.perform_async(spans)
    end
    return span.succeed
  end

  # @return [MeasurementCollection, NilClass]
  # bypassしているプロセスから呼ばれる
  def self.pop_measurement_collection
    ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.pop
  end

  # @param [MeasurementCollection] spans
  # @return [ProconBypassMan::Procon::PerformanceMeasurement::MeasurementsSummarizer::PerformanceMetric]
  # jobから呼ばれる予定
  def self.summarize(spans: )
    ProconBypassMan::Procon::PerformanceMeasurement::MeasurementsSummarizer.new(spans: spans).summarize
  end
end
