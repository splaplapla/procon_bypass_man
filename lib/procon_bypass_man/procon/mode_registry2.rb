class ProconBypassMan::Procon::ModeRegistry2
  class Mode
    attr_accessor :name, :binaries, :source_binaries

    def initialize(name: , binaries: )
      self.name = name
      self.binaries = binaries
      self.source_binaries = binaries.dup
    end

    def next_binary
      binary = binaries.shift
      unless binary
        self.binaries = source_binaries.dup
        return binaries.shift
      end
      return binary
    end
  end

  attr_accessor :plugins

  PRESETS = {
    manual: [],
  }

  def initialize
    self.plugins = {}
  end

  def install_plugin(klass)
    if plugins[klass.to_s.to_sym]
      raise "#{klass} mode is already registered"
    end
    plugins[klass.to_s.to_sym] = ->{ klass.binaries }
  end

  def load(name)
    b = PRESETS[name] || plugins[name]&.call || raise("#{name} is unknown mode")
    Mode.new(name: name, binaries: b.dup)
  end

  def presets
    PRESETS
  end
end
