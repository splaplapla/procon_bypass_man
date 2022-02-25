class ProconBypassMan::Procon
  require "procon_bypass_man/procon/consts"
  require "procon_bypass_man/procon/mode_registry"
  require "procon_bypass_man/procon/macro"
  require "procon_bypass_man/procon/macro_registry"
  require "procon_bypass_man/procon/macro_builder"
  require "procon_bypass_man/procon/layer_changer"
  require "procon_bypass_man/procon/button_collection"
  require "procon_bypass_man/procon/user_operation"
  require "procon_bypass_man/procon/flip_cache"
  require "procon_bypass_man/procon/press_button_aware"

  attr_accessor :user_operation

  def self.reset!
    @@status = {
      buttons: {},
      current_layer_key: :up,
      ongoing_macro: MacroRegistry.load(:null),
      ongoing_mode: ModeRegistry.load(:manual),
    }
    @@left_stick_hypotenuse_summarizer = ProconBypassMan::AnalogStickHypotenuseSummarizer.new
  end
  reset!

  # @param [string] binary
  def initialize(binary)
    self.user_operation = ProconBypassMan::Procon::UserOperation.new(
      binary.dup
    )
  end

  def status; @@status[:buttons]; end
  def ongoing_macro; @@status[:ongoing_macro]; end
  def ongoing_mode; @@status[:ongoing_mode]; end
  def current_layer_key; @@status[:current_layer_key]; end

  def current_layer
    ProconBypassMan::ButtonsSettingConfiguration.instance.layers[current_layer_key]
  end

  def apply!
    layer_changer = ProconBypassMan::Procon::LayerChanger.new(binary: user_operation.binary)
    if layer_changer.change_layer?
      @@status[:current_layer_key] = layer_changer.next_layer_key if layer_changer.pressed_next_layer?
      user_operation.set_no_action!
      return
    end

    analog_stick = ProconBypassMan::Procon::AnalogStick.new(binary: user_operation.binary.raw)
    summarizable_chunk = @@left_stick_hypotenuse_summarizer.add({ hypotenuse: analog_stick.relative_hypotenuse })

    if ongoing_macro.finished?
      current_layer.macros.each do |macro_name, options|
        if options[:if_tilted_left_stick]
          next unless summarizable_chunk
          ProconBypassMan.logger.info "moving_power: #{summarizable_chunk.moving_power}, current_position_x,y: [#{analog_stick.relative_x}, #{analog_stick.relative_y}]"
          if ProconBypassMan::TiltingStickAware.tilting?(summarizable_chunk.moving_power, current_position_x: analog_stick.relative_x, current_position_y: analog_stick.relative_y) && user_operation.pressing_all_buttons?(options[:if_pressed])
            @@status[:ongoing_macro] = MacroRegistry.load(macro_name)
            break
          end

          next
        end

        if user_operation.pressing_all_buttons?(options[:if_pressed])
          @@status[:ongoing_macro] = MacroRegistry.load(macro_name)
        end
      end
    end

    case current_layer.mode
    when :manual
      @@status[:ongoing_mode] = ModeRegistry.load(:manual)
      current_layer.flip_buttons.each do |button, options|
        if !options[:if_pressed]
          FlipCache.fetch(key: button, expires_in: options[:flip_interval]) do
            status[button] = !status[button]
          end
          next
        end

        if options[:if_pressed] && user_operation.pressing_all_buttons?(options[:if_pressed])
          FlipCache.fetch(key: button, expires_in: options[:flip_interval]) do
            status[button] = !status[button]
          end
        else
          FlipCache.fetch(key: button, expires_in: options[:flip_interval]) do
            status[button] = false
          end
        end
      end
    else
      unless ongoing_mode.name == current_layer.mode
        @@status[:ongoing_mode] = ProconBypassMan::Procon::ModeRegistry.load(current_layer.mode)
      end
      if(binary = ongoing_mode.next_binary)
        self.user_operation.merge([binary].pack("H*"))
      end
      return
    end

    status
  end

  # @return [ProconBypassMan::Domains::ProcessingProconBinary]
  def to_binary
    if ongoing_mode.name != :manual
      return user_operation.binary.raw
    end

    if ongoing_macro.ongoing?
      step = ongoing_macro.next_step or return(user_operation.binary.raw)
      user_operation.press_button_only(step)
      return user_operation.binary.raw
    end

    current_layer.disables.each do |button|
      user_operation.unpress_button(button)
    end

    current_layer.left_analog_stick_caps.each do |config|
      if config[:if_pressed].nil? || user_operation.pressing_all_buttons?(config[:if_pressed])
        config[:force_neutral]&.each do |force_neutral_button|
          user_operation.unpress_button(force_neutral_button)
        end
        user_operation.apply_left_analog_stick_cap(cap: config[:cap])
      end
    end

    current_layer.flip_buttons.each do |button, options|
      # 何もしないで常に連打
      if !options[:if_pressed] && status[button]
        user_operation.press_button(button)
        next
      end

      # 押している時だけ連打
      if options[:if_pressed] && user_operation.pressing_all_buttons?(options[:if_pressed])
        if !status[button]
          user_operation.unpress_button(button)
        end

        options[:force_neutral]&.each do |force_neutral_button|
          user_operation.unpress_button(force_neutral_button)
        end
      end
    end

    current_layer.remaps.each do |from_button, to_buttons|
      if user_operation.pressing_button?(from_button)
        user_operation.unpress_button(from_button)
        to_buttons[:to].each do |to_button|
          user_operation.press_button(to_button)
        end
      end
    end

    user_operation.binary.raw
  end

  private

  def method_missing(name)
    if name.to_s =~ /\Apressed_[a-z]+\?\z/
      user_operation.public_send(name)
    else
      super
    end
  end
end
