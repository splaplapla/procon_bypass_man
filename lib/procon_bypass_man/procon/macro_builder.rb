# frozen_string_literal: true

class ProconBypassMan::Procon::MacroBuilder
  class SubjectMerger
    def self.merge(subjects)
      if subjects.size == 1
        return subjects.first.to_steps
      end

      subjects.inject([[], []]) do |acc, item|
        acc[0] << item.to_steps[0]
        acc[1] << item.to_steps[1]
        acc
      end
    end
  end

  class Subject
    def initialize(value)
      if not /^shake_/ =~ value
        @button =
          if match = value.match(/_(\w+)\z/)
            match[1]
          else
            :unknown
          end
      end
      @type =
        if value.start_with?("toggle_")
          :toggle
        elsif value.start_with?("shake_left_stick")
          :shake_left_stick
        else
          :pressing
        end
    end

    def to_steps
      case @type
      when :toggle
        [@button.to_sym, :none]
      when :pressing
        [@button.to_sym, @button.to_sym]
      when :shake_left_stick
        [:tilt_left_stick_completely_to_left, :tilt_left_stick_completely_to_right]
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

    # NOTE: マクロ構文で生成したいけど、スティックとボタン同時押しの構文が思いつかないので、ハードコードする
    if /rotate_left_stick_for_forward_ikarole/ =~ step
      # NOTE: 0degはx: 1, y: 0, 90degはx: 0, y: 1, 180degはx: -1, y: 0.
      for_forward_ikarole_steps = 90.upto(359).map.with_index { |x, index|
        ["tilt_left_stick_completely_to_#{x}deg".to_sym, :zl] if(index % 20 == 0)
      }.compact
      for_forward_ikarole_steps << [:tilt_left_stick_completely_to_0deg, :b, :zl]
      return { steps: for_forward_ikarole_steps }
    end

    if %r!^(pressing_|toggle_|shake_left_stick_)! =~ step && (subjects = step.scan(%r!pressing_[^_]+|shake_left_stick|toggle_[^_]+!)) && (match = step.match(%r!_for_([\d_]+)(sec)?\z!))
      if sec = match[1]
        return {
          continue_for: to_f(sec),
          steps: SubjectMerger.merge(subjects.map { |x| Subject.new(x) }).select { |x|
            if x.is_a?(Array)
              x.select { |y| is_button(y) || RESERVED_WORD_NONE == y }
            else
              is_button(x) || RESERVED_WORD_NONE == x || :tilt_left_stick_completely_to_left == x || :tilt_left_stick_completely_to_right == x
            end
          },
        }
      end
    end

    if %r!^(pressing_|toggle_|shake_left_stick_)! =~ step && (subjects = step.scan(%r!pressing_[^_]+|shake_left_stick|toggle_[^_]+!))
      return SubjectMerger.merge(subjects.map { |x| Subject.new(x) }).select { |x|
        if x.is_a?(Array)
          x.select { |y| is_button(y) || RESERVED_WORD_NONE == y }
        else
          is_button(x) || RESERVED_WORD_NONE == x
        end
      }
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
