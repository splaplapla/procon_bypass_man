require 'benchmark'

# measureをして、measureの結果をためて提供する、という責務のクラス
module ProconBypassMan::Procon::PerformanceMeasurement
  class Bucket
    # gb jobから呼ばれる予定
    class Compacter
    end

    include Singleton

    def initialize
      @current_table = {}
      @mutex = Mutex.new
      @list  = []
    end

    def add(measurement: )
      current_key = generate_bucket_key
      if @current_table[current_key].nil?
        @mutex.synchronize { @list.push(@current_table) }
        @current_table = {}
        @current_table[current_key] = []
        @current_table[current_key] << measurement
      else
        @current_table[current_key] << measurement
      end
    end

    def pop_buckets
      @mutex.synchronize { @list.pop }
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

  def self.pop_buckets
    Bucket.instance.pop_buckets
  end
end
