require 'benchmark'

module ProconBypassMan::Procon::PerformanceMeasurement
  class MeasurementCollection
    attr_accessor :timestamp_key, :measurements

    def initialize(timestamp_key: , measurements: )
      self.timestamp_key = timestamp_key
      self.measurements = measurements
    end
  end

  class PerformanceMetrics < Struct.new(:time_taken_p50,
                                        :time_taken_p95,
                                        :time_taken_p99,
                                        :max_time_taken,
                                        :read_error_count,
                                        :write_error_count)
  end

  # jobから呼ばれる予定
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
      max_time_taken = sorted_time_taken.last
      total_read_error_count = @measurements.map(&:read_error_count).sum
      total_write_error_count = @measurements.map(&:write_error_count).sum
      PerformanceMetrics.new(time_taken_p50, time_taken_p95, time_taken_p99, max_time_taken, total_read_error_count, total_write_error_count)
    end

    private

    # @param [Array<any>]
    # @param [Float] percentile
    # @return [Float]
    def percentile(sorted_list: , percentile: )
      values_sorted = sorted_list
      k = (percentile*(values_sorted.length-1)+1).floor - 1
      f = (percentile*(values_sorted.length-1)+1).modulo(1)
      return(values_sorted[k] + (f * (values_sorted[k+1] - values_sorted[k]))).floor(3)
    end
  end

  class Bucket
    include Singleton

    def initialize
      @current_table = {} # 1つのスレッドからしか触らないのでlockはいらない
      @mutex = Mutex.new
      @measurement_collection_list = [] # main threadとjob worker threadから触るのでlockが必要
    end

    # @param [Measurement] measurement
    def add(measurement: )
      current_key = generate_bucket_key
      if @current_table[current_key].nil?
        if not @current_table.empty?
          timestamp_key = @current_table.keys.first
          measurements = @current_table.values.first
          @mutex.synchronize do
            @measurement_collection_list.push(MeasurementCollection.new(timestamp_key: timestamp_key, measurements: measurements))
          end
        end

        @current_table = {}
        @current_table[current_key] = []
        @current_table[current_key] << measurement
      else
        @current_table[current_key] << measurement
      end
    end

    # job workerから呼ばれる
    # @return [ProconBypassMan::Procon::PerformanceMeasurement::MeasurementCollection]
    def pop_measurement_collection
      @mutex.synchronize { @measurement_collection_list.pop }
    end

    private

    def generate_bucket_key
      Time.new.strftime("%Y-%m-%d %H:%M:00%:z")
    end
  end

  class Measurement
    attr_writer :time_taken
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
      yield(Measurement.new)
      return
    end

    measurement = Measurement.new
    measurement.time_taken = Benchmark.realtime { yield(measurement) }
    Bucket.instance.add(measurement: measurement)
  end

  # @return [MeasurementCollection, NilClass]
  def self.pop_measurement_collection
    Bucket.instance.pop_measurement_collection
  end

  # @param [MeasurementCollection] measurements
  # @return [PerformanceMetrics]
  def self.summarize(measurements: )
    MeasurementsSummarizer.new(measurements: measurements).summarize
  end
end
