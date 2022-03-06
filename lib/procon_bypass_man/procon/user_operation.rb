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

  # @param [Symbol, Array<Symbol>] macro_step
  def press_button_only_or_tilt_sticks(macro_step)
    macro_step = [macro_step] if not macro_step.is_a?(Array)
    # スティック操作の時はボタン入力を通す
    binary.set_no_action! if is_button?(macro_step)

    macro_step.uniq.each do |ms|
      next if ProconBypassMan::Procon::MacroBuilder::RESERVED_WORD_NONE == ms

      if is_button?(ms)
        binary.write_as_press_button(ms)
      elsif is_stick?(ms)
        binary.write_as_tilt_left_stick(ms)
      else
        warn "知らないmacro stepです"
      end
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
    pressing_all_buttons?([button])
  end

  # @param [Array<Symbol>] buttons
  # @return [Boolean]
  def pressing_all_buttons?(buttons)
    aware = ProconBypassMan::PressButtonAware.new(@binary.raw)
    buttons.all? { |b| aware.pressing_button?(b) }
  end

  # @return [Boolean]
  def is_button?(button)
    button = [button] if not button.is_a?(Array)

    button.all? do |b|
      !!ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP[b.to_sym]
    end
  end

  # @return [Boolean]
  def is_stick?(step)
    step =~ /\Atilt_/
  end
end
