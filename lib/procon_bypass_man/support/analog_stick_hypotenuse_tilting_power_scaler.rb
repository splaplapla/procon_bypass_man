class ProconBypassMan::AnalogStickTiltingPowerScaler
  DEFAULT_THRESHOLD = 500

  class PowerChunk
    def initialize(list)
      @list = list
    end

    def moving_power
      max = @list.max
      min = @list.min
      moving_power = (max - min).abs
    end

    def tilting?(threshold: DEFAULT_THRESHOLD, current_position_x: , current_position_y: )
      # スティックがニュートラルな時
      if (-200..200).include?(current_position_x) && (-200..200).include?(current_position_y)
        return false
      end

      moving_power >= threshold
    end
  end

  def initialize
    @map = {}
  end

  # @return [NilClass, Chunk] ローテトしたらvalueを返す
  def add_sample(value)
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
      return PowerChunk.new(list)
    else
      return nil
    end
  end
end
