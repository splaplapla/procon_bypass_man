class ProconBypassMan::Procon::MacroBuilder
  def initialize(steps)
    @steps = steps.map(&:to_s)
  end

  # @return [Arary<Symbol>]
  def build
    steps = @steps.map { |step|
      if v1_format?(step: step)
        step
      elsif value = v2_format?(step: step)
        value
      else
        nil
      end
    }
    steps.compact.flatten.map(&:to_sym)
  end

  private

  def v1_format?(step: )
    if is_button(step)
      step
    end
  end

  def v2_format?(step: )
    if(match = step.match(%r!\Atoggle_(.+)\z!)) && (button_candidate = match[1]) && is_button(button_candidate)
      return [button_candidate, :none]
    end
  end

  # @return [Boolean]
  def is_button(step)
    !!ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP[step.to_sym]
  end
end
