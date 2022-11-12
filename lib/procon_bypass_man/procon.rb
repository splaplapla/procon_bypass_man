# frozen_string_literal: true

require "procon_bypass_man/procon/macro_plugin_map"

class ProconBypassMan::Procon
  require "procon_bypass_man/procon/value_objects/analog_stick"
  require "procon_bypass_man/procon/value_objects/analog_stick_position"
  require "procon_bypass_man/procon/value_objects/procon_reader"
  require "procon_bypass_man/procon/value_objects/rumble_binary"
  require "procon_bypass_man/procon/value_objects/binary"
  require "procon_bypass_man/procon/value_objects/bypass_mode"
  require "procon_bypass_man/procon/consts"
  require "procon_bypass_man/procon/performance_measurement"
  require "procon_bypass_man/procon/performance_measurement/queue_over_process"
  require "procon_bypass_man/procon/mode_registry"
  require "procon_bypass_man/procon/macro"
  require "procon_bypass_man/procon/macro_registry"
  require "procon_bypass_man/procon/macro_builder"
  require "procon_bypass_man/procon/layer_changer"
  require "procon_bypass_man/procon/button_collection"
  require "procon_bypass_man/procon/user_operation"
  require "procon_bypass_man/procon/flip_cache"
  require "procon_bypass_man/procon/press_button_aware"
  require "procon_bypass_man/procon/suppress_rumble"
  require "procon_bypass_man/procon/rumbler"

  attr_accessor :user_operation

  def self.reset!
    @@status = {
      ongoing_macro: MacroRegistry.load(:null),
      ongoing_mode: ModeRegistry.load(:manual), # 削除予定
    }
    BlueGreenProcess::SharedVariable.instance.data["buttons"] = {}
    BlueGreenProcess::SharedVariable.instance.data["current_layer_key"] = :up
    BlueGreenProcess::SharedVariable.instance.data["recent_left_stick_hypotenuses"] = []
  end
  reset!

  # @param [string] binary
  def initialize(binary)
    self.user_operation = ProconBypassMan::Procon::UserOperation.new(
      binary.dup
    )
    @left_stick_tilting_power_scaler = ProconBypassMan::AnalogStickTiltingPowerScaler.new
  end

  def status
    BlueGreenProcess::SharedVariable.instance.data["buttons"]
  end

  def current_layer_key
    BlueGreenProcess::SharedVariable.instance.data["current_layer_key"].to_sym
  end

  def current_layer_key=(layer)
    BlueGreenProcess::SharedVariable.instance.data["current_layer_key"] = layer
  end

  RECENT_LEFT_STICK_POSITIONS_LIMIT = 20
  # @param [Float] left_stick_position
  # @return [void]
  def add_recent_left_stick_hypotenuses(left_stick_position)
    if (overflowed_size = BlueGreenProcess::SharedVariable.instance.data["recent_left_stick_hypotenuses"].size - RECENT_LEFT_STICK_POSITIONS_LIMIT)
      overflowed_size.times { BlueGreenProcess::SharedVariable.instance.data["recent_left_stick_hypotenuses"].shift }
    end
    BlueGreenProcess::SharedVariable.instance.data["recent_left_stick_hypotenuses"] << left_stick_position
  end

  def recent_left_stick_hypotenuses
    BlueGreenProcess::SharedVariable.instance.data["recent_left_stick_hypotenuses"]
  end

  def ongoing_macro; @@status[:ongoing_macro]; end
  def ongoing_mode; @@status[:ongoing_mode]; end

  def current_layer
    ProconBypassMan::ButtonsSettingConfiguration.instance.layers[current_layer_key]
  end

  # 内部ステータスを書き換えるフェーズ
  def apply!
    layer_changer = ProconBypassMan::Procon::LayerChanger.new(binary: user_operation.binary)
    if layer_changer.change_layer?
      if layer_changer.pressed_next_layer?
        self.current_layer_key = layer_changer.next_layer_key
        ProconBypassMan::Procon::Rumbler.rumble!
      end
      user_operation.set_no_action!
      return
    end

    analog_stick = ProconBypassMan::Procon::AnalogStick.new(binary: user_operation.binary.raw)
    add_recent_left_stick_hypotenuses(analog_stick.relative_hypotenuse)
    dumped_tilting_power = @left_stick_tilting_power_scaler.calculate(recent_left_stick_hypotenuses)

    enable_all_macro = true
    enable_macro_map = Hash.new {|h,k| h[k] = true }
    current_layer.disable_macros.each do |disable_macro|
      if (disable_macro[:if_pressed] == [true] || user_operation.pressing_all_buttons?(disable_macro[:if_pressed]))
        if disable_macro[:name] == :all
          enable_all_macro = false
        else
          enable_macro_map[disable_macro[:name]] = false
        end
      end
    end

    if ongoing_macro.finished? && enable_all_macro
      current_layer.macros.each do |macro_name, options|
        next unless enable_macro_map[macro_name]

        if(if_tilted_left_stick_value = options[:if_tilted_left_stick])
          threshold = (if_tilted_left_stick_value.is_a?(Hash) && if_tilted_left_stick_value[:threshold]) || ProconBypassMan::AnalogStickTiltingPowerScaler::DEFAULT_THRESHOLD
          if dumped_tilting_power.tilting?(threshold: threshold, current_position_x: analog_stick.relative_x, current_position_y: analog_stick.relative_y) && user_operation.pressing_all_buttons?(options[:if_pressed])
            @@status[:ongoing_macro] = MacroRegistry.load(macro_name)
            break
          end

          next
        end

        if user_operation.pressing_all_buttons?(options[:if_pressed])
          @@status[:ongoing_macro] = MacroRegistry.load(macro_name, force_neutral_buttons: options[:force_neutral])
          break
        end
      end
    end

    # remote macro
    if task = ProconBypassMan::RemoteMacro::TaskQueueInProcess.non_blocking_shift
      no_op_step = :wait_for_0_3 # マクロの最後に固まって最後の入力をし続けるので、無の状態を最後に注入する
      BlueGreenProcess::SharedVariable.extend_run_on_this_process = true
      ProconBypassMan::Procon::MacroRegistry.cleanup_remote_macros!
      macro_name = task.name || "RemoteMacro-#{task.steps.join}".to_sym
      task.steps << no_op_step
      ProconBypassMan::Procon::MacroRegistry.install_plugin(macro_name, steps: task.steps, macro_type: :remote)
      @@status[:ongoing_macro] = MacroRegistry.load(macro_name, macro_type: :remote) do
        GC.start # NOTE: extend_run_on_this_process = true するとGCされなくなるので手動で呼び出す
        ProconBypassMan::PostCompletedRemoteMacroJob.perform_async(task.uuid)
      end
    end

    case current_layer.mode
    when :manual
      @@status[:ongoing_mode] = ModeRegistry.load(:manual)
      current_layer.flip_buttons.each do |button, options|
        if !options[:if_pressed]
          # FIXME マルチプロセス化したので、クラス変数に状態を保持するFlipCacheは意図した挙動にならない. BlueGreenProcess.shared_variables を使って状態をプロセス間で共有すれば動く
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

  # @return [String]
  def to_binary
    if ongoing_mode.name != :manual
      return user_operation.binary.raw
    end

    if ongoing_macro.ongoing? && (step = ongoing_macro.next_step)
      BlueGreenProcess::SharedVariable.extend_run_on_this_process = true
      ongoing_macro.force_neutral_buttons&.each do |force_neutral_button|
        user_operation.unpress_button(force_neutral_button)
      end
      user_operation.press_button_only_or_tilt_sticks(step)
      return user_operation.binary.raw
    end

    current_layer.disables.each do |button|
      user_operation.unpress_button(button)
    end

    current_layer.left_analog_stick_caps.each do |config|
      if !config[:if_pressed] || user_operation.pressing_all_buttons?(config[:if_pressed])
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
end
