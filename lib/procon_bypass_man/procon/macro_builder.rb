class ProconBypassMan::Procon::MacroBuilder
  RESERVED_WORD_NONE = :none
  RESERVED_WORDS = {
    RESERVED_WORD_NONE => true,
  }

  def initialize(steps)
    @steps = steps.map(&:to_s)
  end

  # @return [Arary<Symbol>]
  def build
    steps = @steps.map { |step|
      if is_reserved?(step: step) || v1_format?(step: step)
        step.to_sym
      elsif value = build_if_v2_format?(step: step)
        value
      else
        nil
      end
    }
    steps.compact.flatten
  end

  private

  def is_reserved?(step: )
    RESERVED_WORDS[step.to_sym]
  end

  def v1_format?(step: )
    if is_button(step)
      step
    end
  end

  def build_if_v2_format?(step: )
    # トグル
    if(match = step.match(%r!\Atoggle_(\w+)\z!)) && (button_candidate = match[1]) && is_button(button_candidate)
      button = button_candidate
      return [button.to_sym, :none]
    end

    # トグル + 時間
    if(match = step.match(%r!\Atoggle_(\w+)_for_([\d_]+)sec\z!)) && (button_candidate = match[1]) && is_button(button_candidate)
      button = button_candidate
      sec =  match[2]
      return [
        { continue_for: to_num(sec),
          steps: [button.to_sym, :none]
        }
      ]
    end

    # 押しっぱなし + 時間
    if(match = step.match(%r!\Apressing_(\w+)_for_([\d_]+)sec\z!)) && (button_candidate = match[1]) && is_button(button_candidate)
      button = button_candidate
      sec =  match[2]
      return [
        { continue_for: to_num(sec),
          steps: [button.to_sym]
        }
      ]
    end
  end

  # @return [Boolean]
  def is_button(step)
    !!ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP[step.to_sym]
  end

  def to_num(value)
    if value.include?("_")
      value.sub("_", ".").to_f
    else
      value.to_i
    end
  end
end