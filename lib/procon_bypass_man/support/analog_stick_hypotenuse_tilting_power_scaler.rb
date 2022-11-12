class ProconBypassMan::AnalogStickTiltingPowerScaler
  DEFAULT_THRESHOLD = 500

  class PowerChunk
    def initialize(hypotenuses)
      @hypotenuses = hypotenuses
    end

    def moving_power
      max = @hypotenuses.max
      min = @hypotenuses.min
      moving_power = (max - min).abs
    end

    # @return [Boolean]
    def tilting?(threshold: DEFAULT_THRESHOLD, current_position_x: , current_position_y: )
      # スティックがニュートラルな時
      if (-200..200).include?(current_position_x) && (-200..200).include?(current_position_y)
        return false
      end

      moving_power >= threshold
    end
  end

  # @param [Array<Float>] hypotenuses
  # @return [PowerChunk]
  def calculate(hypotenuses)
    PowerChunk.new(hypotenuses)
  end
end
