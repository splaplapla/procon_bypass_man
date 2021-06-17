class ProconBypassMan::Procon::ModeRegistry
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

  PRESETS = {
    guruguru: ProconBypassMan::Procon::Data::MEANINGLESS.map{|x| [x].pack("H*") },
    manual: [],
  }

  def self.install_plugin(klass)
    if @@mode_plugins[klass.name]
      raise "すでに登録済みです"
    end
    @@mode_plugins[klass.name] = klass.binaries
  end

  def self.load(name)
    list = PRESETS[name] || plugins[name] || raise("unknown mode")
    Mode.new(name: name, binaries: list.dup)
  end

  def self.reset!
    @@mode_plugins = {}
  end

  def self.plugins
    @@mode_plugins
  end

  reset!
end
