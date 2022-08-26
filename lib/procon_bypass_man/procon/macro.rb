class ProconBypassMan::Procon::Macro
  class BaseNestedStep
    def initialize(value)
      @hash = value
    end

    private

    def incr_step_index!
      if step_index
        @hash[:step_index] += 1
      else
        @hash[:step_index] = 0
      end
    end

    def current_step
      @hash[:steps][step_index]
    end
  end

  class OnetimeNestedStep < BaseNestedStep
    def over?
      current_step.nil?
    end

    def next_step
      step = current_step
      incr_step_index!
      step
    end

    private

    def step_index
      @hash[:step_index] ||= 0
    end
  end

  class NestedStep < BaseNestedStep
    def initialize(value)
      super
      unless @hash[:end_at]
        @hash[:end_at] = (Time.now + @hash[:continue_for]).round(4)
      end
    end

    def over?
      (@hash[:end_at] < Time.now).tap do |result|
        if result
          ProconBypassMan.logger.debug { "[Macro] nested step is finished(#{@hash})" }
        end
      end
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

    def step_index
      @hash[:step_index]
    end

    def reset_step_index!
      @hash[:step_index] = 0
    end
  end

  attr_accessor :name, :steps, :after_callback_block, :force_neutral_buttons

  def initialize(name: , steps: , force_neutral_buttons: [], &after_callback_block)
    self.name = name
    self.steps = steps
    self.after_callback_block = after_callback_block
    self.force_neutral_buttons = force_neutral_buttons # 外部から呼ばれるだけ
  end

  def next_step
    step = steps.first
    if step.is_a?(Symbol)
      return steps.shift
    end

    if step.is_a?(Hash)
      nested_step =
        if step[:continue_for]
          NestedStep.new(step)
        else
          OnetimeNestedStep.new(step)
        end

      if nested_step.over?
        steps.shift # NestedStepを破棄する
        self.after_callback_block.call if self.after_callback_block && steps.empty?
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
