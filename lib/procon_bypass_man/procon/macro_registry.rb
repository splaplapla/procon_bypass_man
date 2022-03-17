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

  # @return [ProconBypassMan::Procon::Macro]
  def self.load(name)
    if(steps = PRESETS[name] || plugins[name]&.call)
      return ProconBypassMan::Procon::Macro.new(name: name, steps: steps.dup)
    else
      warn "installされていないマクロ(#{name})を使うことはできません"
      return self.load(:null)
    end
  end

  def self.reset!
    ProconBypassMan::ButtonsSettingConfiguration.instance.macro_plugins = {}
  end

  def self.plugins
    ProconBypassMan::ButtonsSettingConfiguration.instance.macro_plugins
  end

  def self.cleanup_remote_macros!
  end

  reset!
end
