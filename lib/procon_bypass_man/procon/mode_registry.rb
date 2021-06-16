class ProconBypassMan::Procon::ModeRegistry
  class Mode
    attr_accessor :binaries, :source_binaries

    def initialize(binaries: )
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

  PRESETS = {
    guruguru: {
      binaries: ProconBypassMan::Procon::Data::MEANINGLESS,
    }
  }

  def self.install_plugin(klass)
    if @@mode_plugins[klass.mode_name]
      raise "すでに登録済みです"
    end
    @@mode_plugins[klass.mode_name] = klass.binaries
  end

  def self.load(name)
    binaries = PRESETS[name] || plugins[name] || raise("unknown mode")
    Mode.new(binaries: binaries.dup)
  end

  def self.reset!
    @@mode_plugins = {}
  end

  def self.plugins
    @@mode_plugins
  end

  reset!
end
