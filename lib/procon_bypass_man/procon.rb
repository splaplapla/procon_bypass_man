class ProconBypassMan::Procon
  require "procon_bypass_man/procon/mode_registry"
  require "procon_bypass_man/procon/macro_registry"
  require "procon_bypass_man/procon/layer_changeable"
  require "procon_bypass_man/procon/button_collection"
  require "procon_bypass_man/procon/pushed_button_helper"
  require "procon_bypass_man/procon/user_operation"

  attr_accessor :user_operation

  def self.reset_cvar!
    @@status = {
      buttons: {},
      current_layer_key: :up,
      on_going_macro: MacroRegistry.load(:null),
      on_going_mode: ModeRegistry.load(:manual),
    }
  end
  def self.reset!; reset_cvar!; end
  reset!

  def initialize(binary)
    self.user_operation = ProconBypassMan::Procon::UserOperation.new(binary.dup)
  end

  def status; @@status[:buttons]; end
  def on_going_macro; @@status[:on_going_macro]; end
  def current_layer_key; @@status[:current_layer_key]; end

  def current_layer
    ProconBypassMan::Configuration.instance.layers[current_layer_key]
  end

  def apply!
    if user_operation.change_layer?
      @@status[:current_layer_key] = user_operation.next_layer_key if user_operation.pushed_next_layer?
      user_operation.set_no_action!
      return
    end

    if on_going_macro.finished?
      current_layer.macros.each do |macro_name, options|
        if options[:if_pushed].all? { |b| user_operation.pushed_button?(b) }
          @@status[:on_going_macro] = MacroRegistry.load(macro_name)
        end
      end
    end

    case current_layer.mode
    when :manual
      current_layer.flip_buttons.each do |button, options|
        unless options[:if_pushed]
          status[button] = !status[button]
          next
        end

        if options[:if_pushed] && options[:if_pushed].all? { |b| user_operation.pushed_button?(b) }
          status[button] = !status[button]
        else
          status[button] = false
        end
      end
    else
      unless @@status[:on_going_mode].name == current_layer.mode
        @@status[:on_going_mode] = ProconBypassMan::Procon::ModeRegistry.load(current_layer.mode)
      end
      self.user_operation.merge(target_binary: [@@status[:on_going_mode].next_binary].pack("H*"))
      return
    end

    status
  end

  # @return [String<binary>]
  def to_binary
    if on_going_macro.on_going?
      step = on_going_macro.next_step or return(user_operation.binary)
      user_operation.push_button_only(step)
      return user_operation.binary
    end

    current_layer.flip_buttons.each do |button, options|
      # 何もしないで常に連打
      if !options[:if_pushed] && status[button]
        user_operation.push_button(button)
        next
      end

      # 押している時だけ連打
      if options[:if_pushed] && options[:if_pushed].all? { |b| user_operation.pushed_button?(b) }
        if !status[button]
          user_operation.unpush_button(button)
        end
        if options[:force_neutral] && user_operation.pushed_button?(options[:force_neutral])
          button = options[:force_neutral]
          user_operation.unpush_button(button)
        end
      end
    end
    user_operation.binary
  end

  private

  def method_missing(name)
    if name.to_s =~ /\Apushed_[a-z]+\?\z/
      user_operation.public_send(name)
    else
      super
    end
  end
end
