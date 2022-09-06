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
    else
      warn "error stick manipulator"
      self.manipulated_abs_x = analog_stick.abs_x
      self.manipulated_abs_y = analog_stick.abs_y
    end
  end


  # @return [String]
  def to_binary
    ProconBypassMan::AnalogStickPosition.new(
      x: self.manipulated_abs_x,
      y: self.manipulated_abs_y,
    ).to_binary
  end
end
