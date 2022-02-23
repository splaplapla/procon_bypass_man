class ProconBypassMan::TimeScopedMap
  def initialize
    @duration = 60
    @map = {}
    @result = nil
  end

  def add(value)
    if @map[key].nil?
      rotate
      @map = { key => [] }
    end

    @map[key] << value
  end

  def result
    @result || {}
  end

  private

  # 0.1sec刻みで進行する
  def key
    t = Time.now.to_i
    @duration - (t % @duration)
  end

  def rotate
    @result = { list: @map.values.first }
  end
end
