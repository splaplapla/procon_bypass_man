class ProconBypassMan::Procon::MacroRegistry
  PRESETS = {
    null: [],
  }

  def self.install_plugin(klass, steps: nil, macro_type: :normal)
    if plugins.fetch([klass.to_s.to_sym, macro_type], nil)
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
    if(steps = PRESETS[name] || plugins.fetch([name.to_s.to_sym, macro_type], nil)&.call)
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
    remote_keys = ProconBypassMan::Procon::MacroRegistry.plugins.original_keys.select { |_, y| y == :remote }
    remote_keys.each do |remote_key|
      ProconBypassMan::Procon::MacroRegistry.plugins.delete(remote_key)
    end
    ProconBypassMan::Procon::MacroRegistry.plugins
  end

  reset!
end
