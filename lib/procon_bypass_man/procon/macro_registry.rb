class ProconBypassMan::Procon::MacroRegistry
  PRESETS = {
    null: [],
  }

  def self.install_plugin(klass, steps: nil)
    if plugins[klass.to_s.to_sym]
      raise "#{klass} macro is already registered"
    end

    plugins[klass.to_s.to_sym] = ->{
      ProconBypassMan::Procon::MacroBuilder.new(steps || klass.steps).build
    }
  end

  def self.load(name)
    steps = PRESETS[name] || plugins[name].call || raise("unknown macro")
    ProconBypassMan::Procon::Macro.new(name: name, steps: steps.dup)
  end

  def self.reset!
    ProconBypassMan::ButtonsSettingConfiguration.instance.macro_plugins = {}
  end

  def self.plugins
    ProconBypassMan::ButtonsSettingConfiguration.instance.macro_plugins
  end

  reset!
end
