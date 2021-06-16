class ProconBypassMan::Procon::MacroRegistry
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

  def self.install_plugin(klass)
    if @@macro_plugins[klass.mode_name]
      raise "すでに登録済みです"
    end
    @@macro_plugins[klass.mode_name] = klass.steps
  end

  def self.load(name)
    steps = PRESETS[name] || plugins[name] || raise("unknown macro")
    Macro.new(name: name, steps: steps.dup)
  end

  def self.reset!
    @@macro_plugins = {}
  end

  def self.plugins
    @@macro_plugins
  end

  reset!
end
