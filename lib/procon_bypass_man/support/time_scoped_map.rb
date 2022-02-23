class ProconBypassMan::TimeScopedMap
  def initialize
    @map = {}
    @result = nil
  end

  def add(value, &block)
    current_key = key
    if @map[current_key].nil?
      rotate
      block.call(result) if block_given? && result[:list]
      @map = { current_key => [] }
    end

    @map[current_key] << value
  end

  def result
    @result || {}
  end

  private

  # 0.1sec刻みで進行する
  def key
    time = Time.now
    m1 = time.strftime('%L')[0]
    [time.to_i, m1].join.to_i
  end

  def rotate
    @result = { list: @map.values.first }
  end
end
