# ボタンを押しているか判断するクラス。バイナリの書き換えはしない
class ProconBypassMan::Procon::UserOperation
  attr_reader :binary

  ASCII_ENCODING = "ASCII-8BIT"

  ::ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP.each do |button, _value|
    define_method "pressed_#{button}?" do
      pressed_button?(button)
    end
  end

  # @param [String] binary
  def initialize(binary)
    unless binary.encoding.name == ASCII_ENCODING
      raise "おかしいです"
    end

    @binary = ProconBypassMan::Domains::ProcessingProconBinary.new(binary: binary)
  end

  def set_no_action!
    binary.set_no_action!
  end

  def apply_left_analog_stick_cap(cap: )
    binary.write_as_apply_left_analog_stick_cap(cap: cap)
  end

  # @param [Symbol] button
  def unpress_button(button)
    return if not pressed_button?(button)
    binary.write_as_unpress_button(button)
  end

  # @param [Symbol] button
  def press_button(button)
    return if pressed_button?(button)
    binary.write_as_press_button(button)
  end

  # @param [Symbol] button
  def press_button_only(button)
    binary.write_as_press_button_only(button)
  end

  # @return [void]
  def merge(target_binary)
    binary.write_as_merge!(
      ProconBypassMan::Domains::ProcessingProconBinary.new(binary: target_binary)
    )
  end

  # @param [Symbol] button
  # @return [Boolean]
  def pressed_button?(button)
    ProconBypassMan::PressButtonAware.new(@binary.raw).pressed_button?(button)
  end
end
