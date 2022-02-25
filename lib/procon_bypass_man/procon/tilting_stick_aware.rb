class ProconBypassMan::TiltingStickAware
  def self.tilting?(moving_power, current_position_x: , current_position_y: )
    return false if !moving_power
    # スティックがニュートラルな時
    if (-200..200).include?(current_position_x) && (-200..200).include?(current_position_y)
      return false
    end

    moving_power > 300
  end
end
