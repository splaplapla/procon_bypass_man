class ProconBypassMan::Procon::MacroRegistry
  PRESETS = {
    null: [],
  }

  def self.install_plugin(klass, steps: nil, macro_type: :normal)
    if plugins[klass.to_s.to_sym]
      raise "#{klass} macro is already registered"
    end

    plugins.store(
      [klass.to_s.to_sym, macro_type], ->{
        ProconBypassMan::Procon::MacroBuilder.new(steps || klass.steps).build
      }
    )
  end

  # @return [ProconBypassMan::Procon::Macro]
  def self.load(name, macro_type: :normal)
    if(steps = PRESETS[name] || plugins.fetch([name, macro_type], nil)&.call)
      return ProconBypassMan::Procon::Macro.new(name: name, steps: steps.dup)
    else
      warn "installされていないマクロ(#{name})を使うことはできません"
      return self.load(:null)
    end
  end

  def self.reset!
    ProconBypassMan::ButtonsSettingConfiguration.instance.macro_plugins = ProconBypassMan::Procon::MacroPluginMap.new
  end

  def self.plugins
    ProconBypassMan::ButtonsSettingConfiguration.instance.macro_plugins
  end

  def self.cleanup_remote_macros!
  end

  reset!
end
