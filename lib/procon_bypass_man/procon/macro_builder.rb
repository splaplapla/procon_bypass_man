class ProconBypassMan::Procon::MacroBuilder
  class SubjectMerger
    def self.merge(subjects)
      if subjects.size == 1
        return subjects.first.to_steps
      end

      base = subjects.first
      remain = subjects[1..-1]
      remain.map { |x| base.to_steps.zip(x.to_steps) }.first
    end
  end

  class Subject
    def initialize(value)
      @button =
        if match = value.match(/_(\w+)\z/)
          match[1]
        else
          :unknown
        end
      @type =
        if value.start_with?("toggle_")
          :toggle
        else
          :pressing
        end
    end

    def toggle?
      @type == :toggle
    end

    def pressing?
      not toggle?
    end

    def to_steps
      case @type
      when :toggle
        [@button.to_sym, :none]
      when :pressing
        [@button.to_sym, @button.to_sym]
      end
    end
  end

  RESERVED_WORD_NONE = :none
  RESERVED_WORDS = {
    RESERVED_WORD_NONE => true,
  }

  def initialize(steps)
    @steps = steps.map(&:to_s)
  end

  # @return [Arary<Symbol>]
  def build
    steps = @steps.flat_map { |step|
      if is_reserved?(step: step) || v1_format?(step: step)
        step.to_sym
      elsif value = build_if_v2_format?(step: step)
        value
      else
        nil
      end
    }

    steps.compact
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
    # no-op command
    if(match = step.match(%r!wait_for_([\d_]+)(sec)?\z!))
      sec = match[1]
      return [
        { continue_for: to_f(sec),
          steps: [:none],
        }
      ]
    end

    if %r!^(pressing_|toggle_)! =~ step && (subjects = step.scan(%r!pressing_[^_]+|toggle_[^_]+!)) && (match = step.match(%r!_for_([\d_]+)(sec)?\z!))
      if sec = match[1]
        return {
          continue_for: to_f(sec),
          steps: SubjectMerger.merge(subjects.map { |x| Subject.new(x) }).select { |x|
            if x.is_a?(Array)
              x.select { |y| is_button(y) || RESERVED_WORD_NONE == y }
            else
              is_button(x) || RESERVED_WORD_NONE == x
            end
          },
        }
      end
    end

    if %r!^(pressing_|toggle_)! =~ step && (subjects = step.scan(%r!pressing_[^_]+|toggle_[^_]+!))
      return SubjectMerger.merge(subjects.map { |x| Subject.new(x) }).select { |x|
        if x.is_a?(Array)
          x.select { |y| is_button(y) || RESERVED_WORD_NONE == y }
        else
          is_button(x) || RESERVED_WORD_NONE == x
        end
      }
    end

    if(match = step.match(%r!shake_left_stick_for_([\d_]+)(sec)?\z!))
      sec = match[1]
      return [
        { continue_for: to_f(sec),
          steps: [:tilt_left_stick_completely_to_left, :tilt_left_stick_completely_to_right],
        }
      ]
    end
  end

  # @return [Boolean]
  def is_button(step)
    !!ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP[step.to_sym]
  end

  def to_f(value)
    if value.include?("_")
      value.sub("_", ".").to_f
    else
      value.to_f
    end
  end
end
