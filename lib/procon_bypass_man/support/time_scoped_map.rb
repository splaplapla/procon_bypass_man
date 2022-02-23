class ProconBypassMan::TimeScopedMap
  def initialize
    @map = {}
    @result = nil
  end

  def add(value, &block)
    rotated = false
    current_key = key
    if @map[current_key].nil?
      rotate
      if result[:list]
        if block_given?
          block.call(result)
        end
        rotated = true
      end
      @map = { current_key => [] }
    end

    @map[current_key] << value
    rotated
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
