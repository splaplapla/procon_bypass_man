class ProconBypassMan::AnalogStickHypotenuseSummarizer
  class SummarizableChunk
    def initialize(list)
      @list = list
    end

    def moving_power
      max = @list.max {|a, b| a[:hypotenuse] <=> b[:hypotenuse] }
      min = @list.min {|a, b| a[:hypotenuse] <=> b[:hypotenuse] }
      moving_power = (max[:hypotenuse] - min[:hypotenuse]).abs
    end
  end

  def initialize
    @map = {}
  end

  def add(value, &block)
    rotated = nil
    current_key = key
    if @map[current_key].nil?
      rotated = rotate
      @map = { current_key => [] } # renew or initialize
    end

    @map[current_key] << value
    rotated
  end

  private

  # 0.1sec刻みで進行する
  def key
    time = Time.now
    m1 = time.strftime('%L')[0]
    [time.to_i, m1].join.to_i
  end

  def rotate
    list = @map.values.first
    if list
      return SummarizableChunk.new(list)
    else
      return nil
    end
  end
end
