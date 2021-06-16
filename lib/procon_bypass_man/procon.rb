class ProconBypassMan::Procon
  require "procon_bypass_man/procon/layer_changeable"
  require "procon_bypass_man/procon/button_collection"
  require "procon_bypass_man/procon/pushed_button_helper"
  require "procon_bypass_man/procon/user_operation"

  attr_accessor :user_operation

  def self.reset_cvar!
    @@status = {
      buttons: {},
      auto_mode_sequence: 0,
      current_layer_key: :up,
      on_going_macro: ProconBypassMan::MacroRegistry.load(:null),
    }
  end
  reset_cvar!

  def initialize(binary)
    self.user_operation = ProconBypassMan::Procon::UserOperation.new(binary.dup)
  end

  def status; @@status[:buttons]; end
  def on_going_macro; @@status[:on_going_macro]; end
  def current_layer_key; @@status[:current_layer_key]; end
  def auto_mode_sequence; @@status[:auto_mode_sequence]; end

  def current_layer
    ProconBypassMan::Configuration.instance.layers[current_layer_key]
  end

  def apply!
    # layer変更中はニュートラルにする
    if user_operation.change_layer?
      @@status[:current_layer_key] = user_operation.next_layer_key if user_operation.pushed_next_layer?
      user_operation.set_no_action!
      return
    end

    if on_going_macro.finished?
      current_layer.macros.each do |macro_name, options|
        if options[:if_pushed].all? { |b| user_operation.pushed_button?(b) }
          @@status[:on_going_macro] = ProconBypassMan::MacroRegistry.load(macro_name)
        end
      end
    end

    case
    when current_layer.mode == :auto
      data = ProconBypassMan::Procon::Data::MEANINGLESS[auto_mode_sequence]
      if data.nil?
        auto_mode_sequence = 0
        data = ProconBypassMan::Procon::Data::MEANINGLESS[auto_mode_sequence]
      end
      auto_mode_sequence += 1
      auto_binary = [data].pack("H*")
      user_operation.binary[3] = auto_binary[3]
      user_operation.binary[4] = auto_binary[4]
      user_operation.binary[5] = auto_binary[5]
      user_operation.binary[6] = auto_binary[6]
      user_operation.binary[7] = auto_binary[7]
      user_operation.binary[8] = auto_binary[8]
      user_operation.binary[9] = auto_binary[9]
      user_operation.binary[10] = auto_binary[10]
      user_operation.binary[11] = auto_binary[11]
      return
    else
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
    end

    status
  end

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
