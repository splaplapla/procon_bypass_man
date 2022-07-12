class ProconBypassMan::Procon::PerformanceMeasurement::SpanQueue
  def initialize
    @current_table = {} # 1つのスレッドからしか触らないのでlockはいらない
    @measurement_collection_list = [] # main threadとjob worker threadから触るのでlockが必要
  end

  # @param [Array<PerformanceSpan>] spans
  # bypassプロセスから呼ばれる. 実際に実行を行なっているのはmasterプロセス
  def push(new_spans)
    current_key = generate_bucket_key

    if @current_table[current_key].nil?
      if not @current_table.empty?
        timestamp_key = @current_table.keys.first
        spans = @current_table.values.first
        # 本当ならmutexでlockする必要があるけど、正確性はいらないのでパフォーマンスを上げるためにlockしない
        @measurement_collection_list.push(
          ProconBypassMan::Procon::PerformanceMeasurement::MeasurementCollection.new(timestamp_key: timestamp_key, spans: spans)
        )
      end

      @current_table = {}
      @current_table[current_key] = []
      @current_table[current_key].concat(new_spans)
    else
      @current_table[current_key].concat(new_spans)
    end
  end

  # job workerから呼ばれる
  # @return [ProconBypassMan::Procon::PerformanceMeasurement::MeasurementCollection]
  def pop
    @measurement_collection_list.pop
  end

  private

  # 1分単位で次の値になる
  def generate_bucket_key
    Time.new.strftime("%Y-%m-%d %H:%M:00%:z")
  end
end
