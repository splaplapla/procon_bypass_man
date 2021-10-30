# read
class ProconBypassMan::ReadonlyProController
  def initialize(binary: )
    @binary = binary
    @user_operation = ProconBypassMan::Procon::UserOperation.new(binary.dup)
  end

  # @return [Array<Symbol>]
  def pressed
    pressed_table = ::ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP.keys.reduce({}) do |acc, button|
      acc[button] = @user_operation.pressed_button?(button)
      acc
    end
    pressed_table.select { |key, value| value }
  end

  def left_analog_stick
    { x: 0, y: 0 }
  end

  def to_hash
    { left_analog_stick: left_analog_stick,
      pressed_buttons: pressed.keys,
    }
  end
end
