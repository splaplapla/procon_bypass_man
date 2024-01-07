# frozen_string_literal: true

class ProconBypassMan::Procon::MacroRegistry
  PRESETS = {
    null: [],
  }

  def self.install_plugin(klass, steps: nil, macro_type: :normal)
    if plugins.fetch([klass.to_s.to_sym, macro_type], nil)
      Kernel.warn "#{klass} macro is already registered"
      return
    end

    plugins.store(
      [klass.to_s.to_sym, macro_type], ->{
        ProconBypassMan::Procon::MacroBuilder.new(steps || klass.steps).build
      }
    )
  end

  # @return [ProconBypassMan::Procon::Macro]
  def self.load(name, macro_type: :normal, force_neutral_buttons: [], &after_callback_block)
    if(steps = PRESETS[name] || plugins.fetch([name.to_s.to_sym, macro_type], nil)&.call)
      return ProconBypassMan::Procon::Macro.new(name: name, steps: steps.dup, force_neutral_buttons: force_neutral_buttons, &after_callback_block)
    else
      warn "installされていないマクロ(#{name})を使うことはできません"
      return self.load(:null)
    end
  end

  # TODO: シングルトンをやめたらこれを削除する
  def self.reset!
    ProconBypassMan.buttons_setting_configuration.macro_plugins = ProconBypassMan::Procon::MacroPluginMap.new
  end

  def self.plugins
    ProconBypassMan.buttons_setting_configuration.macro_plugins
  end

  def self.cleanup_remote_macros!
    remote_keys = ProconBypassMan::Procon::MacroRegistry.plugins.original_keys.select { |_, y| y == :remote }
    remote_keys.each do |remote_key|
      ProconBypassMan::Procon::MacroRegistry.plugins.delete(remote_key)
    end
    ProconBypassMan::Procon::MacroRegistry.plugins
  end
end
