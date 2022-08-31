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
                                       :gc_count,
                                       :gc_time,
                                       :succeed_rate); end

  def initialize(spans: )
    @spans = spans
  end

  # @return [PerformanceMetric]
  # NOTE 中央値の表示価値が低いのでコメントアウト
  def summarize

    write_time_max = 0
    read_time_max = 0
    time_taken_max = 0
    interval_from_previous_succeed_max = 0
    @spans.each do |span|
      # NOTE @spans.map(&:write_time).sort.last と同じことだけど、処理コストを軽くするためにループを共通化する
      write_time_max = span.write_time if write_time_max < span.write_time
      read_time_max = span.read_time if write_time_max < span.read_time
      time_taken_max = span.time_taken if span.succeed && time_taken_max < span.time_taken
      interval_from_previous_succeed_max = span.interval_from_previous_succeed if span.succeed && interval_from_previous_succeed_max < span.interval_from_previous_succeed
    end

    # NOTE 今はGCを無効にしており、集計するまでもないのでコメントアウトにする. 今後GCを有効にしたバイパスをするかもしれないので残しておく
    gc_count = 0 # @spans.map(&:gc_count).sum
    gc_time = 0 # @spans.map(&:gc_time).sum

    # sorted_interval_from_previous_succeed = @spans.select(&:succeed).map(&:interval_from_previous_succeed).sort
    # interval_from_previous_succeed_max = sorted_interval_from_previous_succeed.last || 0
    interval_from_previous_succeed_p50 = 0 # percentile(sorted_list: sorted_interval_from_previous_succeed , percentile: 0.50)

    # sorted_read_time = @spans.map(&:read_time).sort
    read_time_p50 = 0 # percentile(sorted_list: sorted_read_time , percentile: 0.50)
    # read_time_max = sorted_read_time.last || 0

    # sorted_write_time = @spans.map(&:write_time).sort
    write_time_p50 = 0 # percentile(sorted_list: sorted_write_time , percentile: 0.50)
    # write_time_max = sorted_write_time.last || 0

    # sorted_time_taken = @spans.select(&:succeed).map(&:time_taken).sort
    time_taken_p50 = 0 # percentile(sorted_list: sorted_time_taken, percentile: 0.50)
    time_taken_p95 = 0 # percentile(sorted_list: sorted_time_taken, percentile: 0.95)
    time_taken_p99 = 0 # percentile(sorted_list: sorted_time_taken, percentile: 0.99)
    # time_taken_max = sorted_time_taken.last || 0

    # NOTE webに表示していないのでコメントアウト. デバッグ時に見ることがあるので残しておく
    total_read_error_count = 0 # @spans.map(&:read_error_count).sum
    total_write_error_count = 0 # @spans.map(&:write_error_count).sum

    # succeed_rate =
    #   if @spans.length.zero?
    #     0
    #   else
    #     succeed_rate = (sorted_time_taken.length / @spans.length.to_f).floor(3)
    #   end
    succeed_rate = 1 # Switchへの書き込みに失敗した時にretryしているので100%になるようになってる. succeedの個数をカウントコストを減らすためにハードコード

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
                          gc_count,
                          gc_time,
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
