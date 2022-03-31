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
        case if_pressed
        when TrueClass
          if_pressed = [button]
        when Symbol, String
          if_pressed = [if_pressed.to_sym]
        when Array
          if_pressed = if_pressed.map(&:to_sym).uniq
        when FalseClass, NilClass
          if_pressed = false
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
          return
        end

        hash = { if_pressed: if_pressed }
        case force_neutral
        when TrueClass
          Kernel.warn "設定ファイルに記述ミスがあります. #{force_neutral}を受け取りました. flipのforce_neutralにはボタンを渡してください."
          return
        when Symbol, String
          hash[:force_neutral] = [force_neutral.to_sym]
        when Array
          hash[:force_neutral] = force_neutral.map(&:to_sym).uniq
        when FalseClass, NilClass
          # no-op
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
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
        if if_pressed.nil?
          Kernel.warn "設定ファイルに記述ミスがあります. macroのif_pressedはボタンを渡してください."
          return
        end

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

        case force_neutral
        when Array
          force_neutral = force_neutral.map(&:to_sym).uniq
        when String, Symbol
          force_neutral = [force_neutral].map(&:to_sym).uniq
        when Integer, TrueClass
          warn "macro #{name}のforce_neutralで想定外の値です"
          return
        when NilClass
          # no-op
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
          return
        end

        case if_pressed
        when Array
          if_pressed = if_pressed.map(&:to_sym).uniq
        when String, Symbol
          if_pressed = [if_pressed].map(&:to_sym).uniq
        when Integer, TrueClass, FalseClass
          warn "macro #{name}のif_pressedで想定外の値です"
          return
        when NilClass
          Kernel.warn "設定ファイルに記述ミスがあります. macroのif_pressedはボタンを渡してください."
          return # これはトリガーなので必須
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
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

        if steps.nil?
          Kernel.warn "設定ファイルに記述ミスがあります. open_macroのstepsは値を渡してください."
          return
        end

        case steps
        when Array
          steps = steps.map(&:to_sym)
        when Integer, TrueClass, NilClass, FalseClass
          warn "macro #{name}のstepsで想定外の値です"
          return
        when String, Symbol
          steps = [steps.to_sym]
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
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
        rescue ParamNormalizer::UnexpectedValueError
          Kernel.warn "設定ファイルに記述ミスがあります. open_macroのforce_neutralで未対応の値を受け取りました."
          return
        end

        case if_pressed
        when Array
          if_pressed = if_pressed.map(&:to_sym).uniq
        when String, Symbol
          if_pressed = [if_pressed].map(&:to_sym).uniq
        when Integer, TrueClass, FalseClass
          warn "macro #{name}のif_pressedで想定外の値です"
          return
        when NilClass
          Kernel.warn "設定ファイルに記述ミスがあります. macroのif_pressedはボタンを渡してください."
          return # これはトリガーなので必須
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
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
        case if_pressed
        when TrueClass, FalseClass
          return # booleanはよくわからないのでreturn
        when Symbol, String
          hash[:if_pressed] = [if_pressed.to_sym]
        when Array
          hash[:if_pressed] = if_pressed.map(&:to_sym).uniq
        when NilClass # 常に対象のmacroをdisableにする
          hash[:if_pressed] = [true]
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
          return
        end

        disable_macros << hash
      end

      def remap(button, to: )
        case button
        when TrueClass, FalseClass, NilClass, Array, Integer
          Kernel.warn "設定ファイルに記述ミスがあります. リマップ対象にはボタンを渡してください."
          return
        when Symbol, String
          button = button.to_sym
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
          return
        end

        case to
        when TrueClass, FalseClass, NilClass
          Kernel.warn "設定ファイルに記述ミスがあります. toにボタンを渡してください."
          return
        when Symbol, String
          self.remaps[button] = { to: [to.to_sym] }
        when Array
          if to.size.zero?
            Kernel.warn "設定ファイルに記述ミスがあります. toにボタンを渡してください."
            return
          end
          self.remaps[button] = { to: to.map(&:to_sym).uniq }
        else
          Kernel.warn "設定ファイルに記述ミスがあります. 未対応の値を受け取りました."
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

        case if_pressed
        when TrueClass, FalseClass
          Kernel.warn "設定ファイルに記述ミスがあります. left_analog_stick_capのif_pressedにはボタンを渡してください."
          return
        when Symbol, String
          if_pressed = [if_pressed.to_sym]
        when Array
          if_pressed = if_pressed.map(&:to_sym).uniq
        when NilClass
          # no-op
        else
          Kernel.warn "設定ファイルに記述ミスがあります. left_analog_stick_capのif_pressedで未対応の値を受け取りました."
          return
        end

        if if_pressed
          hash[:if_pressed] = if_pressed
        end

        begin
          if(force_neutral = ParamNormalizer::ForceNeutral.new(force_neutral).to_value!)
            hash[:force_neutral] = force_neutral
          end
        rescue ParamNormalizer::UnSupportValueError
          Kernel.warn "設定ファイルに記述ミスがあります. left_analog_stick_capのforce_neutralにはボタンを渡してください."
          return
        rescue ParamNormalizer::UnexpectedValueError
          Kernel.warn "設定ファイルに記述ミスがあります. left_analog_stick_capのforce_neutralで未対応の値を受け取りました."
          return
        end

        left_analog_stick_caps << hash
      end

      def disable(button)
        ParamNormalizer::ButtonList.new(button).to_a!.each do |disable|
          disables  << disable
        end
        disables.uniq!
      rescue ParamNormalizer::UnSupportValueError
        Kernel.warn "設定ファイルに記述ミスがあります. disableにはボタンを渡してください."
        return
      rescue ParamNormalizer::UnexpectedValueError
        Kernel.warn "設定ファイルに記述ミスがあります. disableで未対応の値を受け取りました."
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
