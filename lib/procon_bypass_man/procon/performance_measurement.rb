require 'benchmark'

# measureをして、measureの結果をためて提供する、という責務のクラス
module ProconBypassMan::Procon::PerformanceMeasurement
  class MeasurementCollection
    attr_accessor :timestamp_key, :measurements

    def initialize(timestamp_key: , measurements: )
      self.timestamp_key = timestamp_key
      self.measurements = measurements
    end
  end

  class PerformanceMetrics
    attr_accessor :time_taken_agv, :time_taken_max, :time_taken_p99, :time_taken_p95, :read_error_count, :write_error_count
  end

  #  jobから呼ばれる予定
  class MeasurementsSummarizer
  end

  class Bucket
    include Singleton

    def initialize
      @current_table = {} # 1つのスレッドからしか触らないのでlockはいらない
      @mutex = Mutex.new
      @measurement_collection_list = [] # main threadとjob worker threadから触るのでlockが必要
    end

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

  class AbstractMeasurement
    attr_writer :time_taken

    def initialize
      @write_error_count = 0
      @read_error_count = 0
      @time_taken = 0.0
    end
  end

  class NullMeasurement < AbstractMeasurement
    def record_read_error; end
    def record_write_error; end
  end

  class Measurement < AbstractMeasurement
    def record_read_error 
      @read_error_count += 1
    end

    def record_write_error
      @write_error_count += 1
    end
  end

  # @return [void]
  def self.measure(&block)
    unless ProconBypassMan.config.enable_procon_performance_measurement?
      yield(NullMeasurement.new)
      return 
    end

    measurement = Measurement.new
    measurement.time_taken = Benchmark.realtime { yield(measurement) }
    Bucket.instance.add(measurement: measurement)
  end

  # @return [ProconBypassMan::Procon::PerformanceMeasurement::MeasurementCollection]
  def self.pop_measurement_collection
    Bucket.instance.pop_measurement_collection
  end

  # @param [] measurements
  # @return [ProconBypassMan::Procon::PerformanceMeasurement::ProconPerformanceMetrics]
  def self.summarize(measurements: )
    measurements.reduce()
    PerformanceMetrics.new()
  end
end
