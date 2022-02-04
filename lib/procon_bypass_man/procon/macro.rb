class ProconBypassMan::Procon::Macro
  attr_accessor :name, :steps

  def initialize(name: , steps: )
    self.name = name
    self.steps = steps
  end

  def next_step
    steps.shift
  end

  def finished?
    steps.empty?
  end

  def ongoing?
    !finished?
  end
end
