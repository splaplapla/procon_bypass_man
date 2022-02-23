class ProconBypassMan::StickPositionsList
  def initialize(list)
    @list = list
  end

  def moving_power
    max = @list.max {|a, b| a[:hypotenuse] <=> b[:hypotenuse] }[:hypotenuse]
    min = @list.min {|a, b| a[:hypotenuse] <=> b[:hypotenuse] }[:hypotenuse]
    (max - min).abs
  end
end
