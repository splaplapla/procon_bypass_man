module ProconBypassMan
  class ButtonsSettingConfiguration
    class Layer
      attr_accessor :mode, :flips, :macros, :disable_macros, :remaps, :left_analog_stick_caps, :disables

      def initialize(mode: :manual)
        self.mode = mode
        self.flips = {}
        self.macros = {}
        self.disable_macros = []
        self.remaps = {}
        self.left_analog_stick_caps = []
        self.disables = []
      end

      # @param [Symbol] button
      def flip(button, if_pressed: false, force_neutral: nil, flip_interval: nil)
        begin
          if_pressed = ParamNormalizer::FlipIfPressed.new(if_pressed, button: button).to_value!
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. flipのif_pressedにはボタンを渡してください."
          return
        end

        hash = { if_pressed: if_pressed }

        begin
          if(force_neutral = ParamNormalizer::ForceNeutral.new(force_neutral).to_value!)
            hash[:force_neutral] = force_neutral
          end
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. flipのforce_neutralにはボタンを渡してください."
          return
        end

        if flip_interval
          if /\A(\d+)F\z/i =~ flip_interval
            interval =  ((frame = $1.to_i) / 60.0).floor(2)
          else
            raise "8F みたいなフォーマットで入力してください"
          end
          hash[:flip_interval] = interval
        end

        self.flips[button] = hash
      end

      # @param [String, Class] プラグインのclass
      def macro(name, if_pressed: nil, if_tilted_left_stick: nil, force_neutral: nil)
        case if_tilted_left_stick
        when Integer, String, Symbol, Array
          warn "macro #{name}のif_tilted_left_stickで想定外の値です"
          if_tilted_left_stick = nil
        when TrueClass, NilClass, FalseClass
          # OK
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
          return
        end

        begin
          if(fn = ParamNormalizer::ForceNeutral.new(force_neutral).to_value!)
            force_neutral = fn
          end
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. macroのforce_neutralにはボタンを渡してください."
          return
        end

        begin
          if_pressed = ParamNormalizer::IfPressed.new(if_pressed).to_value!
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. macroのif_pressedにはボタンを渡してください."
          return
        end

        macro_name = name.to_s.to_sym
        if ProconBypassMan::ButtonsSettingConfiguration.instance.macro_plugins[macro_name]
          self.macros[macro_name] = { if_pressed: if_pressed, if_tilted_left_stick: if_tilted_left_stick, force_neutral: force_neutral }.compact
        else
          warn "#{macro_name}マクロがinstallされていません"
        end
      end

      # 設定ファイルに直接マクロを打ち込める
      # @param [String, Class] macroの識別子
      # @paramh[Array<Symbol>] macroの本体. ボタンの配列
      def open_macro(name, steps: [], if_pressed: nil, if_tilted_left_stick: nil, force_neutral: nil)
        if name.nil?
          Kernel.warn "設定ファイルに記述ミスがあります. open_macroのnameには一意になる名前を渡してください."
          return
        end

        begin
          steps = ParamNormalizer::OpenMacroSteps.new(steps).to_value!
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. open_macroのstepsには文字列の配列を渡してください."
          return
        end

        case if_tilted_left_stick
        when Integer, String, Symbol, Array
          warn "macro #{name}のif_tilted_left_stickで想定外の値です"
          if_tilted_left_stick = nil
        when TrueClass, NilClass, FalseClass, Hash
          # OK
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
          return
        end

        begin
          force_neutral = ParamNormalizer::ForceNeutral.new(force_neutral).to_value!
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. open_macroのforce_neutralにはボタンを渡してください."
          return
        end

        begin
          if_pressed = ParamNormalizer::IfPressed.new(if_pressed).to_value!
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. open_macroのif_pressedにはボタンを渡してください."
          return
        end

        macro_name = name || "OpenMacro-#{steps.join}".to_sym
        ProconBypassMan::Procon::MacroRegistry.install_plugin(macro_name, steps: steps)
        self.macros[macro_name] = { if_pressed: if_pressed, if_tilted_left_stick: if_tilted_left_stick, force_neutral: force_neutral }.compact
      end

      def disable_macro(name, if_pressed: nil)
        if name.nil?
          Kernel.warn "設定ファイルに記述ミスがあります. disable_macroのnameにはmacro nameかクラス名の名前を渡してください."
          return
        end

        hash = { name: name.to_s.to_sym, if_pressed: [] }
        begin
          if(if_pressed = ParamNormalizer::DisableMacroIfPressed.new(if_pressed).to_value!)
            hash[:if_pressed] = if_pressed
          end
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. disable_macroのif_pressedにはボタンを渡してください."
          return
        end

        disable_macros << hash
      end

      def remap(button, to: )
        begin
          button = ParamNormalizer::Button.new(button).to_value!
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. disable_macroのif_pressedにはボタンを渡してください."
          return
        end

        begin
          self.remaps[button] = { to: ParamNormalizer::ButtonList.new(to).to_value! }
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. remapのtoにはボタンを渡してください."
          return
        end
      end

      def left_analog_stick_cap(cap: nil, if_pressed: nil, force_neutral: nil)
        case cap
        when Integer
          # OK
        when Float
          cap = cap.to_i
        else
          Kernel.warn "設定ファイルに記述ミスがあります. left_analog_stick_capのcapで未対応の値を受け取りました."
          return
        end

        hash = { cap: cap }

        begin
          if(if_pressed = ParamNormalizer::IfPressedAllowsFalsy.new(if_pressed).to_value!)
            hash[:if_pressed] = if_pressed
          end
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. left_analog_stick_capのif_pressedにはボタンを渡してください."
          return
        end

        begin
          if(force_neutral = ParamNormalizer::ForceNeutral.new(force_neutral).to_value!)
            hash[:force_neutral] = force_neutral
          end
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. left_analog_stick_capのforce_neutralにはボタンを渡してください."
          return
        end

        left_analog_stick_caps << hash
      end

      def disable(button)
        ParamNormalizer::ButtonList.new(button).to_value!.each do |disable|
          disables << disable
        end
        disables.uniq!
      rescue ParamNormalizer::UnSupportValueError
        Kernel.warn "設定ファイルに記述ミスがあります. disableにはボタンを渡してください."
        return
      end

      # @return [Array]
      def flip_buttons
        flips
      end

      # @return [String]
      def to_json(*)
        to_hash.to_json
      end

      # @return [Hash]
      def to_hash
        { mode: mode,
          flips: flips,
          macros: macros,
          remaps: remaps,
          disables: disables,
          left_analog_stick_caps: left_analog_stick_caps,
        }
      end
    end
  end
end
