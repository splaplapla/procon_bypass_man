class ProconBypassMan::Procon::Macro
  class NestedStep
    def initialize(value)
      @hash = value
      unless @hash[:end_at]
        @hash[:end_at] = (Time.now + @hash[:continue_for]).round(4)
      end
    end

    def over_end_at?
      (@hash[:end_at] < Time.now).tap do |result|
        if result
          ProconBypassMan.logger.debug { "[Macro] nested step is finished(#{@hash})" }
        end
      end
    end

    def next_step
      incr_step_index!

      debug_incr_called_count!
      if step = current_step
        return step
      else
        reset_step_index!
        return current_step
      end
    end

    private

    def current_step
      @hash[:steps][step_index]
    end

    def step_index
      @hash[:step_index]
    end

    def incr_step_index!
      if step_index
        @hash[:step_index] += 1
      else
        @hash[:step_index] = 0
      end
    end

    def reset_step_index!
      @hash[:step_index] = 0
    end

    def debug_incr_called_count!
      @hash[:debug_called_count] ||= 0
      @hash[:debug_called_count] += 1
    end
  end

  attr_accessor :name, :steps

  def initialize(name: , steps: )
    self.name = name
    self.steps = steps
  end

  def next_step
    step = steps.first
    if step.is_a?(Symbol)
      return steps.shift
    end

    if step.is_a?(Hash)
      nested_step = NestedStep.new(step)
      if nested_step.over_end_at?
        steps.shift # NestedStepを破棄する
        return next_step
      else
        return nested_step.next_step
      end
    end
  end

  def finished?
    steps.empty?
  end

  def ongoing?
    !finished?
  end
end
