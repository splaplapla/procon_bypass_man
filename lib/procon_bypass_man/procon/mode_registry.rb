class ProconBypassMan::Procon::ModeRegistry
  class Mode
    attr_accessor :binaries

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

  PaRESETS = {
    guruguru: {
      binaries: ProconBypassMan::Procon::Data::MEANINGLESS,
    }
  }

  def self.load(name)
    binaries = PRESETS[name] || raise("unknown mode")
    Mode.new(binaries: binaries.dup)
  end
end
