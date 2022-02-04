class ProconBypassMan::Procon::Macro
  class NestedStep
    def initialize(value)
      @hash = value
      unless @hash[:end_at]
        @hash[:end_at] = Time.now + @hash[:continue_for]
      end
    end

    def over_end_at?
      @hash[:end_at] <= Time.now
    end

    def next_step
      incr_step_index!

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
      end
      return nested_step.next_step
    end
  end

  def finished?
    steps.empty?
  end

  def ongoing?
    !finished?
  end
end
