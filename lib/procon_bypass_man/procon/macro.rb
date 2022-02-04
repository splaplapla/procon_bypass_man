class ProconBypassMan::Procon::Macro
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
      nested_step = step
      steps = nested_step[:steps]
      if nested_step.key?(:step_index)
        nested_step[:step_index] += 1
      else
        nested_step[:step_index] = 0
      end

      if step = nested_step[:steps][nested_step[:step_index]]
        return step
      else
        nested_step[:step_index] = 0
        return nested_step[:steps][nested_step[:step_index]]
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
