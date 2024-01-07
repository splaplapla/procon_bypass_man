# frozen_string_literal: true

class ProconBypassMan::Procon::AnalogStickManipulator
  attr_accessor :manipulated_abs_x, :manipulated_abs_y

  def initialize(binary, method: )
    analog_stick = ProconBypassMan::Procon::AnalogStick.new(binary: binary)

    if method =~ /tilt_left_stick_(completely)_to_(left|right)/
      power_level = $1
      direction = $2

      case direction
      when 'left'
        self.manipulated_abs_x = 400
        # yを引き継ぐとタンサンボムの溜まりが悪くなったので固定値を入れる
        self.manipulated_abs_y = analog_stick.abs_y
        # self.manipulated_abs_y = 1808
      when 'right'
        self.manipulated_abs_x = 3400
        self.manipulated_abs_y = 1808
      end

      return
    end

    if method =~ /tilt_left_stick_(completely)_to_(\d+)deg/
      power_level = $1
      arc_degree = $2.to_i
      syahen = 1800 # 最大まで傾けた状態
      neutral_position = ProconBypassMan.buttons_setting_configuration.neutral_position
      self.manipulated_abs_x = (syahen * Math.cos(arc_degree * Math::PI / 180)).to_i - neutral_position.x
      self.manipulated_abs_y = (syahen * Math.sin(arc_degree * Math::PI / 180)).to_i - neutral_position.y
      return
    end

    warn "error stick manipulator"
    self.manipulated_abs_x = analog_stick.abs_x
    self.manipulated_abs_y = analog_stick.abs_y
  end


  # @return [String]
  def to_binary
    ProconBypassMan::AnalogStickPosition.new(
      x: self.manipulated_abs_x,
      y: self.manipulated_abs_y,
    ).to_binary
  end
end
