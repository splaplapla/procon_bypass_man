class ProconBypassMan::Procon::PerformanceMeasurement::SpanQueue
  class MeasurementCollection
    # TODO rename from measurements to spans
    attr_accessor :timestamp_key, :spans

    def initialize(timestamp_key: , spans: )
      self.timestamp_key = timestamp_key
      self.spans = spans
    end
  end

  def initialize
    @current_table = {} # 1つのスレッドからしか触らないのでlockはいらない
    @mutex = Mutex.new
    @measurement_collection_list = [] # main threadとjob worker threadから触るのでlockが必要
  end

  # @param [PerformanceSpan] span
  # bypassプロセスから呼ばれる
  def push(span)
    current_key = generate_bucket_key

    if @current_table[current_key].nil?
      if not @current_table.empty?
        timestamp_key = @current_table.keys.first
        spans = @current_table.values.first
        @mutex.synchronize do
          @measurement_collection_list.push(MeasurementCollection.new(timestamp_key: timestamp_key, spans: spans))
        end
      end

      @current_table = {}
      @current_table[current_key] = []
      @current_table[current_key] << span
    else
      @current_table[current_key] << span
    end
  end

  # job workerから呼ばれる
  # @return [ProconBypassMan::Procon::PerformanceMeasurement::MeasurementCollection]
  def pop
    @mutex.synchronize { @measurement_collection_list.pop }
  end

  private

  def generate_bucket_key
    Time.new.strftime("%Y-%m-%d %H:%M:00%:z")
  end
end
