# frozen_string_literal: true

class ProconBypassMan::Procon::MacroRegistry2
  attr_accessor :plugins

  PRESETS = {
    null: [],
  }

  def initialize
    self.plugins = ProconBypassMan::Procon::MacroPluginMap.new
  end

  def install_plugin(klass, steps: nil, macro_type: :normal)
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
  def load(name, macro_type: :normal, force_neutral_buttons: [], &after_callback_block)
    if(steps = PRESETS[name] || plugins.fetch([name.to_s.to_sym, macro_type], nil)&.call)
      return ProconBypassMan::Procon::Macro.new(name: name, steps: steps.dup, force_neutral_buttons: force_neutral_buttons, &after_callback_block)
    else
      warn "installされていないマクロ(#{name})を使うことはできません"
      return self.load(:null)
    end
  end


  def cleanup_remote_macros!
    remote_keys = plugins.original_keys.select { |_, y| y == :remote }
    remote_keys.each do |remote_key|
      plugins.delete(remote_key)
    end
    plugins
  end
end
