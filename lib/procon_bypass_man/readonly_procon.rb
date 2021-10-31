# read
class ProconBypassMan::ReadonlyProcon
  def initialize(binary: )
    @binary = binary
    @user_operation = ProconBypassMan::Procon::UserOperation.new(binary.dup)
    @analog_stick = ProconBypassMan::Procon::AnalogStick.new(binary: binary)
  end

  # @return [Array<Symbol>]
  def pressed
    pressed_table = ::ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP.keys.reduce({}) do |acc, button|
      acc[button] = @user_operation.pressed_button?(button)
      acc
    end
    pressed_table.select { |_key, value| value }.keys
  end

  def left_analog_stick
    { x: @analog_stick.relative_x, y: @analog_stick.relative_y }
  end

  def to_hash
    { left_analog_stick: left_analog_stick,
      pressed_buttons: pressed,
    }
  end
end