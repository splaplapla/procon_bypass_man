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
    manual: [],
  }

  def self.install_plugin(klass)
    if plugins[klass.to_s.to_sym]
      raise "#{klass} mode is already registered"
    end
    plugins[klass.to_s.to_sym] = ->{ klass.binaries }
  end

  def self.load(name)
    b = PRESETS[name] || plugins[name]&.call || raise("#{name} is unknown mode")
    Mode.new(name: name, binaries: b.dup)
  end

  def self.reset!
    ProconBypassMan::ButtonsSettingConfiguration.instance.mode_plugins = {}
  end

  def self.plugins
    ProconBypassMan::ButtonsSettingConfiguration.instance.mode_plugins
  end

  reset!
end
