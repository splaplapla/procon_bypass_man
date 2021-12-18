module ProconBypassMan
  class ButtonsSettingConfiguration
    class Layer
      attr_accessor :mode, :flips, :macros, :remaps, :left_analog_stick_caps, :disables

      def initialize(mode: :manual)
        self.mode = mode
        self.flips = {}
        self.macros = {}
        self.remaps = {}
        self.left_analog_stick_caps = {}
        self.disables = []
      end

      # @param [Symbol] button
      def flip(button, if_pressed: false, force_neutral: nil, flip_interval: nil)
        case if_pressed
        when TrueClass
          if_pressed = [button]
        when Symbol, String
          if_pressed = [if_pressed]
        when Array
          # if_pressed = if_pressed
        when FalseClass, NilClass
          # no-op
        else
          raise "not support class"
        end

        hash = { if_pressed: if_pressed }
        case force_neutral
        when TrueClass
          raise "ボタンを渡してください"
        when Symbol, String
          hash[:force_neutral] = [force_neutral]
        when Array
          hash[:force_neutral] = force_neutral
        when FalseClass, NilClass
          # no-op
        else
          raise "not support value"
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

      def macro(name, if_pressed: )
        if name.respond_to?(:name)
          macro_name = name.name.to_sym
        else
          macro_name = name
        end
        self.macros[macro_name] = { if_pressed: if_pressed }
      end

      def remap(button, to: )
        case to
        when TrueClass, FalseClass, NilClass
          raise "ボタンを渡してください"
        when Symbol, String
          self.remaps[button] = { to: [to] }
        when Array
          raise "ボタンを渡してください" if to.size.zero?
          self.remaps[button] = { to: to }
        end
      end

      def left_analog_stick_cap(cap: , if_pressed: nil, force_neutral: nil)
        hash = { cap: cap }

        case if_pressed
        when TrueClass, FalseClass
          raise "ボタンを渡してください"
        when Symbol, String
          if_pressed = [if_pressed]
        when Array, NilClass
          # no-op
        else
          raise "not support value"
        end

        case force_neutral
        when TrueClass
          raise "ボタンを渡してください"
        when Symbol, String
          hash[:force_neutral] = [force_neutral]
        when Array
          hash[:force_neutral] = force_neutral
        when FalseClass, NilClass
          # no-op
        else
          raise "not support value"
        end

        left_analog_stick_caps[if_pressed] = hash
      end

      def disable(button)
        case button
        when TrueClass, FalseClass, NilClass
          raise "not support class"
        when Symbol
          disables << button
        when String
          disables << button.to_sym
        when Array
          button.each { |b| disables << b }
        else
          raise "not support value"
        end
      end

      # @return [Array]
      def flip_buttons
        flips
      end
    end
  end
end
