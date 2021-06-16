class ProconBypassMan::MacroRegistry
  class Macro
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

    def on_going?
      !finished?
    end
  end

  PRESETS = {
    null: [],
    fast_return: [:down, :a, :a, :x, :down, :a, :a].freeze,
  }

  def self.load(name)
    steps = PRESETS[name]
    Macro.new(name: name, steps: PRESETS[name].dup)
  end
end
