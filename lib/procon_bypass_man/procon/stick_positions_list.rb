class ProconBypassMan::StickPositionsList
  def initialize(list)
    @list = list
  end

  def moving_power
    max = @list.max {|a, b| a[:hypotenuse] <=> b[:hypotenuse] }
    min = @list.min {|a, b| a[:hypotenuse] <=> b[:hypotenuse] }
    { power: (max[:hypotenuse] - min[:hypotenuse]).abs, max: max[:relative], min: min[:relative] }
  end
end
