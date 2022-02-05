# ボタンを押しているか判断するクラス。バイナリの書き換えはしない
class ProconBypassMan::Procon::UserOperation
  attr_reader :binary

  ASCII_ENCODING = "ASCII-8BIT"

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
    return if not pressing_button?(button)
    binary.write_as_unpress_button(button)
  end

  # @param [Symbol] button
  def press_button(button)
    return if pressing_button?(button)
    binary.write_as_press_button(button)
  end

  # @param [Symbol, Array<Symbol>] button
  def press_button_only(button)
    if button.is_a?(Array)
      binary.set_no_action!
      button.each do |b|
        unless ProconBypassMan::Procon::MacroBuilder::RESERVED_WORD_NONE == b
          binary.write_as_press_button(b)
        end
      end
      return
    end

    if ProconBypassMan::Procon::MacroBuilder::RESERVED_WORD_NONE == button
      binary.set_no_action!
    else
      binary.write_as_press_button_only(button)
    end
  end

  # @return [void]
  def merge(target_binary)
    binary.write_as_merge!(
      ProconBypassMan::Domains::ProcessingProconBinary.new(binary: target_binary)
    )
  end

  # @param [Symbol] button
  # @return [Boolean]
  def pressing_button?(button)
    ProconBypassMan::PressButtonAware.new(@binary.raw).pressing_button?(button)
  end

  # @param [Array<Symbol>] buttons
  # @return [Boolean]
  def pressing_all_buttons?(buttons)
    aware = ProconBypassMan::PressButtonAware.new(@binary.raw)
    buttons.all? { |b| aware.pressing_button?(b) }
  end
end
